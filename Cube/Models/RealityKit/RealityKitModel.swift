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
    let arView = ARView(frame: .zero)
    let scene: Scene
    let cubeEntity = Entity()

    let yawEntity = Entity()
    let pitchEntity = Entity()
    let rotationEntity = Entity()

    let cameraAnchor = AnchorEntity()

    var pieceEntities: [Entity] = []
    var animationCompletion: Cancellable? = nil

    init() {
        cubeEntity.addChild(rotationEntity)
        scene = arView.scene

        setupCamera()
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

    func run(move: Move, duration: Double, afterAction: @escaping () -> Void) {
    }

    func hitTest(at: CGPoint, cube: Cube) -> Sticker? {
        return nil
    }

    var view: UIView { arView }
}

extension Vector {
    var simd3: SIMD3<Float> {
        simd_float3(x, y, z)
    }
}
