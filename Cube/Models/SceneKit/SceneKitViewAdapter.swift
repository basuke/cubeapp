//
//  SceneKitViewAdapter.swift
//  Cube
//
//  Created by Basuke Suzuki on 10/9/23.
//

import Foundation
import SceneKit

class SceneKitViewAdapter: ViewAdapter {
    let model: SceneKitModel
    let sceneView = SCNView(frame: .zero)

    required init(model: Model) {
        guard let model = model as? SceneKitModel else {
            fatalError("Model is not SceneKitModel")
        }

        self.model = model

        sceneView.scene = model.scene
        sceneView.backgroundColor = .clear
    }
    
    func hitTest(at location: CGPoint, cube: Cube) -> Sticker? {
        let options: [SCNHitTestOption : Any] = [
            .searchMode: SCNHitTestSearchMode.closest.rawValue,
        ]

        guard let result = sceneView.hitTest(location, options: options).first else {
            return nil
        }

        let normal = Vector(model.cubeNode.convertVector(result.worldNormal, from: nil)).rounded

        return model.identifySticker(from: result.node, cube: cube, normal: normal)
    }

    var view: UIView {
        sceneView
    }
}
