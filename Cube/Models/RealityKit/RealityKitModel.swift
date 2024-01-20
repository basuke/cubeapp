//
//  RealityKitModel.swift
//  Cube
//
//  Created by Basuke Suzuki on 10/2/23.
//

import Foundation
import RealityKit
import UIKit
import Combine
import Spatial

let kRadiusOfCube: Float = 1.5 * sqrtf(3.0)

class RealityKitModel: Model {
    let cubeEntity = Entity()
    let entity = Entity()

    let yawEntity = Entity()
    let pitchEntity = Entity()
    let rotationEntity = Entity()

    var pieceEntities: [Entity] = []
    var lookingRight: Bool = true

    init() {
        rotationEntity.components[RotationComponent.self] = RotationComponent()

        cubeEntity.addChild(rotationEntity)

        // Add the box node to the scene
        entity.addChild(yawEntity)
        yawEntity.addChild(pitchEntity)
        pitchEntity.addChild(cubeEntity)
    }

    func reset() {
        removeDirectionButtonEntity()
    }

    func rebuild(with cube: Cube) {
        let mesh = MeshResource.generateBox(size: 1.0, cornerRadius: 0.1)
        let material = SimpleMaterial(color: .init(white: 0.1, alpha: 1.0), isMetallic: false)

        let coreMesh = MeshResource.generateSphere(radius: 1.4)
        let coreEntity = ModelEntity(mesh: coreMesh, materials: [material])
        cubeEntity.addChild(coreEntity)

        let thickness: Float = 0.1

        func createPiece(_ piece: Piece) -> Entity {
            let entity = ModelEntity(mesh: mesh, materials: [material])

            for (face, color) in piece.colors {
                entity.addChild(createSticker(on: face, color: color))
            }

            entity.position = piece.position.vectorf
#if os(visionOS)
            entity.components.set(GroundingShadowComponent(castsShadow: true))
#endif
            return entity
        }

        func createSticker(on face: Face, color: Color) -> Entity {
            let mesh = MeshResource.generateBox(width: 0.8, height: 0.8, depth: thickness, cornerRadius: 0.1)
            let material = SimpleMaterial(color: color.uiColor, isMetallic: false)

            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.transform = stickerTransform(for: face)
            entity.generateCollisionShapes(recursive: false)
            entity.components.set(StickerComponent(color: color))
#if os(visionOS)
            entity.components.set(HoverEffectComponent())
            entity.components.set(InputTargetComponent())
#endif
            return entity
        }

        func stickerTransform(for face: Face) -> Transform {
            let halfPi = Float.pi / 2
            var transform: Transform = switch face {
            case .front: Transform()
            case .up: Transform(pitch: -halfPi, yaw: 0, roll: 0)
            case .right: Transform(pitch: 0, yaw: halfPi, roll: 0)
            case .back: Transform(pitch: 0, yaw: .pi, roll: 0)
            case .down: Transform(pitch: halfPi, yaw: 0, roll: 0)
            case .left: Transform(pitch: 0, yaw: -halfPi, roll: 0)
            }

            let d = 0.5 - Double(thickness) / 3
            let position = Vector(face.axis.vector) * d
            transform.translation = position.vectorf
            return transform
        }

        pieceEntities.forEach { $0.removeFromParent() }
        pieceEntities = cube.pieces.map { createPiece($0) }
        pieceEntities.forEach { cubeEntity.addChild($0) }
    }

    func run(move: Move, duration: Double) -> AnyPublisher<Void, Never> {
        rotationEntity.transform = .init()

        movePiecesIntoRotation(for: move)
        return rotationEntity.apply(move: move, duration: duration)
            .map { _ in
                self.movePiecesBackFromRotation()
            }.eraseToAnyPublisher()
    }

    private func movePiecesIntoRotation(for move: Move) {
        let predicate = move.filter
        let pieces = pieceEntities.filter { entity in
            predicate( Vector(entity.position))
        }
        pieces.forEach { entity in
            rotationEntity.addChild(entity, preservingWorldTransform: true)
        }
    }

    private func movePiecesBackFromRotation() {
        let entities = rotationEntity.children.map { $0 }
        entities.forEach { entity in
            cubeEntity.addChild(entity, preservingWorldTransform: true)
            entity.position = Vector(entity.position).rounded.vectorf
        }
    }

    func identifySticker(from entity: Entity, cube: Cube, color: Color) -> Sticker? {
        guard let pieceEntity = entity.parent else {
            return nil
        }

        guard let piece = cube.piece(at: Vector(pieceEntity.position).rounded) else {
            return nil
        }

        return piece.sticker(with: color)
    }
}

extension Transform {
    var eularAngles: EulerAngles {
        let rotation = Rotation3D(rotation)
        return rotation.eulerAngles(order: .xyz)
    }
}

extension EulerAngles {
    var x: Float {
        Float(angles.x)
    }

    var y: Float {
        Float(angles.y)
    }

    var z: Float {
        Float(angles.z)
    }
}

extension RealityKitModel {
    func setCameraYaw(ratio: Float) {
        let yaw = initialYaw * ratio
        yawEntity.transform = Transform(pitch: 0.0, yaw: yaw, roll: 0.0)
    }

    var yaw: Float {
        get { yawEntity.transform.eularAngles.y }
        set { yawEntity.transform = Transform(pitch: 0, yaw: newValue, roll: 0) }
    }

    var pitch: Float {
        get { pitchEntity.transform.eularAngles.x }
        set { pitchEntity.transform = Transform(pitch: newValue, yaw: 0, roll: 0) }
    }

    func updateCamera(direction: Direction?) {
        if let direction {
            switch direction {
            case .up:
                setPitch(.pi / 4 * 3 - (.pi / 10))
            case .down:
                setPitch(-.pi / 4 - (.pi / 10))
            case .left:
                setYaw(.pi / 4)
                lookingRight = false
            case .right:
                setYaw(-.pi / 4)
                lookingRight = true
            }
        } else {
            setPitch(.pi / 4 - (.pi / 10))
            setYaw(.pi / 8 * (lookingRight ? -1 : 1))
        }
    }

    func setYaw(_ value: Float, speed: TurnSpeed = .normal) {
        let transform = Transform(pitch: 0, yaw: value, roll: 0)
        yawEntity.move(to: transform, relativeTo: yawEntity.parent, duration: speed.duration, timingFunction: .easeInOut)
    }

    func setPitch(_ value: Float, speed: TurnSpeed = .normal) {
        let transform = Transform(pitch: value, yaw: 0, roll: 0)
        pitchEntity.move(to: transform, relativeTo: pitchEntity.parent, duration: speed.duration, timingFunction: .easeInOut)
    }

    func resetPitch(speed: TurnSpeed = .normal) {
        let transform = Transform(pitch: 0, yaw: 0, roll: 0)
        pitchEntity.move(to: transform, relativeTo: pitchEntity.parent, duration: speed.duration, timingFunction: .easeInOut)
    }
}

extension Vector {
    var vectorf: SIMD3<Float> {
        simd_float3(vector)
    }
}

extension Piece {
    func sticker(with color: Color) -> Sticker? {
        guard let face = colors.first(where: { $1 == color })?.key else {
            return nil
        }

        return sticker(on: face)
    }
}

let kScaleForRealityKit: Float = 0.02

extension RealityKitModel {
    func entity(scale: Float) -> Entity {
        entity.position = simd_float3(0, 0, 0)
        return entity
    }
}
