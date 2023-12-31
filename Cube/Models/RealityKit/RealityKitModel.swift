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

class RealityKitModel: Model {
#if !os(visionOS)
    let arView = ARView(frame: .zero)
#endif

    let cubeEntity = Entity()

    let yawEntity = Entity()
    let pitchEntity = Entity()
    let rotationEntity = Entity()

    let cameraAnchor = AnchorEntity()

    var pieceEntities: [Entity] = []

    var view: UIView {
#if os(visionOS)
        UIView()
#else
        arView
#endif
    }

    init() {
        rotationEntity.components[RotationComponent.self] = RotationComponent()

        cubeEntity.addChild(rotationEntity)

        // Add the box node to the scene
        pitchEntity.addChild(cubeEntity)
        yawEntity.addChild(pitchEntity)

#if !os(visionOS)
        setupCamera(scene: arView.scene)
#endif
    }

    func rebuild(with cube: Cube) {
        let mesh = MeshResource.generateBox(size: 1.0, cornerRadius: 0.1)
        let material = SimpleMaterial(color: .init(white: 0.1, alpha: 1.0), isMetallic: false)

        let thickness: Float = 0.1

        func createPiece(_ piece: Piece) -> Entity {
            let entity = ModelEntity(mesh: mesh, materials: [material])

            for (face, color) in piece.colors {
                entity.addChild(createSticker(on: face, color: color))
            }

            entity.position = piece.position.simd3
            return entity
        }

        func createSticker(on face: Face, color: Color) -> Entity {
            let mesh = MeshResource.generateBox(width: 0.8, height: 0.8, depth: thickness, cornerRadius: 0.1)
            let material = SimpleMaterial(color: color.uiColor, isMetallic: false)

            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.transform = stickerTransform(for: face)
            entity.generateCollisionShapes(recursive: false)
            entity.components.set(StickerComponent(color: color))
            return entity
        }

        func stickerTransform(for face: Face) -> Transform {
            var transform: Transform = switch face {
            case .front, .back: Transform()
            case .up, .down: Transform(pitch: .pi / 2, yaw: 0, roll: 0)
            case .right, .left: Transform(pitch: 0, yaw: .pi / 2, roll: 0)
            }

            let d = 0.5 - Double(thickness) / 3
            let position = face.axis * d
            transform.translation = position.simd3
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
            entity.position = Vector(entity.position).rounded.simd3
        }
    }

    func hitTest(at location: CGPoint, cube: Cube) -> Sticker? {
#if os(visionOS)
        return nil
#else
        guard let result = arView.hitTest(location, query: .nearest).first else {
            return nil
        }

        guard let component = result.entity.components[StickerComponent.self] as StickerComponent? else {
            return nil
        }

        return identifySticker(from: result.entity, cube: cube, color: component.color)
#endif
    }

    private func identifySticker(from entity: Entity, cube: Cube, color: Color) -> Sticker? {
        guard let pieceEntity = entity.parent else {
            return nil
        }

        guard let piece = cube.piece(at: Vector(pieceEntity.position).rounded) else {
            return nil
        }

        return piece.sticker(with: color)
    }
}

extension Vector {
    init(_ simd: SIMD3<Float>) {
        self.init(simd.x, simd.y, simd.z)
    }

    var simd3: SIMD3<Float> {
        simd_float3(x, y, z)
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
