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

class RealityKitModel: Model {
    let cubeEntity = Entity()

    let yawEntity = Entity()
    let pitchEntity = Entity()
    let rotationEntity = Entity()

    var pieceEntities: [Entity] = []

    init() {
        rotationEntity.components[RotationComponent.self] = RotationComponent()

        cubeEntity.addChild(rotationEntity)

        // Add the box node to the scene
        pitchEntity.addChild(cubeEntity)
        yawEntity.addChild(pitchEntity)
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
            var transform: Transform = switch face {
            case .front, .back: Transform()
            case .up, .down: Transform(pitch: .pi / 2, yaw: 0, roll: 0)
            case .right, .left: Transform(pitch: 0, yaw: .pi / 2, roll: 0)
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

let kYawScaleFactorForARKit: Float = 1.7

extension RealityKitModel {
    func setCameraYaw(ratio: Float) {
        let yaw = initialYaw * ratio
        yawEntity.transform = Transform(pitch: 0.0, yaw: yaw * kYawScaleFactorForARKit, roll: 0.0)
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
