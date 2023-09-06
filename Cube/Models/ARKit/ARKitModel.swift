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
            let thickness: Float = 0.1
            let mesh = MeshResource.generateBox(width: 0.8, height: 0.8, depth: thickness, cornerRadius: 0.1)
            let material = SimpleMaterial(color: color.uiColor, isMetallic: false)

            let entity = ModelEntity(mesh: mesh, materials: [material])
            let d: Float = 0.5 - thickness / 3
            switch face {
            case .front:
                entity.position = Vector(0, 0, d).simd3
            case .back:
                entity.position = Vector(0, 0, -d).simd3
            case .up:
                entity.transform = Transform(pitch: .pi / 2, yaw: 0, roll: 0)
                entity.position = Vector(0, d, 0).simd3
            case .down:
                entity.transform = Transform(pitch: .pi / 2, yaw: 0, roll: 0)
                entity.position = Vector(0, -d, 0).simd3
            case .right:
                entity.transform = Transform(pitch: 0, yaw: .pi / 2, roll: 0)
                entity.position = Vector(d, 0, 0).simd3
            case .left:
                entity.transform = Transform(pitch: 0, yaw: .pi / 2, roll: 0)
                entity.position = Vector(-d, 0, 0).simd3
            }

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

    func run(move: Move, duration: Double, afterAction: @escaping () -> Void) {
        DispatchQueue.main.async {
            afterAction()
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
