//
//  ARKitModel.swift
//  Cube
//
//  Created by Basuke Suzuki on 9/5/23.
//

import Foundation
import RealityKit
import UIKit
import Combine

class ARKitModel: Model {
    let arView = ARView(frame: .zero)
    let scene: Scene
    let cubeEntity = Entity()

    let yawEntity = Entity()
    let pitchEntity = Entity()
    let rotationEntity = Entity()

    let cameraAnchor = AnchorEntity()

    var pieceEntities: [Entity] = []
    var animationCompletion: Cancellable? = nil

    let thickness: Float = 0.1

    init() {
        cubeEntity.addChild(rotationEntity)
        scene = arView.scene

        setupCamera()
    }

    func rebuild(with cube: Cube) {
        let mesh = MeshResource.generateBox(size: 1.0, cornerRadius: 0.1)
        let material = SimpleMaterial(color: .init(white: 0.1, alpha: 1.0), isMetallic: false)

        func createPiece(_ piece: Piece) -> Entity {
            let entity = ModelEntity(mesh: mesh, materials: [material])

            piece.stickers.forEach { sticker in
                entity.addChild(createSticker(on: sticker.face, color: sticker.color))
            }

            entity.position = piece.position.simd3
            return entity
        }

        func createSticker(on face: Face, color: Color) -> Entity {
            let mesh = MeshResource.generateBox(width: 0.8, height: 0.8, depth: thickness, cornerRadius: 0.1)
            let material = SimpleMaterial(color: color.uiColor, isMetallic: false)

            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.transform = transform(for: face)
            return entity
        }

        pieceEntities.forEach { $0.removeFromParent() }
        pieceEntities = []

        cube.pieces.forEach { piece in
            let entity = createPiece(piece)
            pieceEntities.append(entity)
            cubeEntity.addChild(entity)
        }
    }

    private func transform(for face: Face) -> Transform {
        let d: Float = 0.5 - thickness / 3

        var transform: Transform = switch face {
        case .front, .back: Transform()
        case .up, .down: Transform(pitch: .pi / 2, yaw: 0, roll: 0)
        case .right, .left: Transform(pitch: 0, yaw: .pi / 2, roll: 0)
        }

        let position = switch face {
        case .right: Vector(d, 0, 0)
        case .left: Vector(-d, 0, 0)
        case .up: Vector(0, d, 0)
        case .down: Vector(0, -d, 0)
        case .front: Vector(0, 0, d)
        case .back: Vector(0, 0, -d)
        }

        transform.translation = position.simd3
        return transform
    }

    func run(move: Move, duration: Double, afterAction: @escaping () -> Void) {
        rotationEntity.transform = .init()

        movePiecesIntoRotation(for: move)
        let transform: Transform = .turn(move: move)

        let controller = rotationEntity.move(to: transform, relativeTo: rotationEntity.parent, duration: duration, timingFunction: .easeOut)

        animationCompletion = scene.publisher(for: AnimationEvents.PlaybackCompleted.self)
            .filter { $0.playbackController == controller }
            .sink(receiveValue: { event in
                self.movePiecesBackFromRotation()
                self.animationCompletion = nil
                afterAction()
            })
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

    func hitTest(at: CGPoint, cube: Cube) -> Sticker? {
        return nil
    }
    
    var view: UIView { arView }
}

extension Vector {
    init(_ simd: SIMD3<Float>) {
        self.init(simd.x, simd.y, simd.z)
    }

    var simd3: SIMD3<Float> {
        simd_float3(x, y, z)
    }
}

extension Transform {
    static func turn(move: Move) -> Transform {
        let rotation = simd_quatf(angle: move.angle, axis: simd_normalize(move.axis.simd3))
        return Transform(rotation: rotation)
    }
}
