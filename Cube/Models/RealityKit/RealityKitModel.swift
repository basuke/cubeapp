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

    func rebuild(with: Cube) {
        let mesh = MeshResource.generateBox(size: 3.0, cornerRadius: 0.1)
        let material = SimpleMaterial(color: .red, isMetallic: true)

        let model = ModelEntity(mesh: mesh, materials: [material])
        cubeEntity.addChild(model)
    }

    func run(move: Move, duration: Double, afterAction: @escaping () -> Void) {
    }

    func hitTest(at: CGPoint, cube: Cube) -> Sticker? {
        return nil
    }

    var view: UIView { arView }
}
