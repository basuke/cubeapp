//
//  SceneKitCoordinator.swift
//  Cube
//
//  Created by Basuke Suzuki on 9/9/23.
//

import SceneKit

class SceneKitViewAdapter: ViewAdapter {
    let sceneKitModel: SceneKitModel
    let sceneKitView = SCNView(frame: .zero)
    var view: UIView { sceneKitView }

    required init(model: Model) {
        guard let model = model as? SceneKitModel else {
            fatalError("Invalid model was passed.")
        }
        sceneKitModel = model
        sceneKitView.scene = model.scene
        sceneKitView.backgroundColor = .clear
    }


    func hitTest(at location: CGPoint, cube: Cube) -> Sticker? {
        let options: [SCNHitTestOption : Any] = [
            .searchMode: SCNHitTestSearchMode.closest.rawValue,
        ]

        guard let result = sceneKitView.hitTest(location, options: options).first else {
            return nil
        }

        let normal = Vector(sceneKitModel.cubeNode.convertVector(result.worldNormal, from: nil)).rounded

        return identifySticker(from: result.node, cube: cube, normal: normal)
    }

    private func identifySticker(from node: SCNNode, cube: Cube, normal: Vector) -> Sticker? {
        guard let pieceNode = node.parent, node.kind == .sticker else {
            return nil
        }

        let position = Vector(pieceNode.position).rounded + (normal * 0.5)
        return cube.stickers.first { $0.position == position }
    }
}
