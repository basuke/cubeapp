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

#if !os(xrOS)

class ARKitViewAdapter: ViewAdapter {
    let model: RealityKitModel
    let arView = ARView(frame: .zero)
    let scene: Scene

    let cameraAnchor = AnchorEntity()

    class SceneActionRunner: ActionRunner {
        var animationCompletion: AnyCancellable? = nil
        var action: Action? = nil

        init(scene: Scene) {
            animationCompletion = scene.publisher(for: AnimationEvents.PlaybackCompleted.self)
                .sink(receiveValue: { event in
                    guard let action = self.action else { return }
                    action()
                })
        }

        func register(action: @escaping Action) {
            self.action = action
        }
    }

    let actionRunner: ActionRunner

    required init(model: Model) {
        guard let model = model as? RealityKitModel else {
            fatalError("Requires RealityKitModel")
        }
        self.model = model
        scene = arView.scene
        actionRunner = SceneActionRunner(scene: scene)
        model.runner = actionRunner

        adjustCamera()
        scene.anchors.append(cameraAnchor)
    }

    func hitTest(at location: CGPoint, cube: Cube) -> Sticker? {
        guard let result = arView.hitTest(location, query: .nearest).first else {
            return nil
        }

        return model.identifySticker(from: result.entity, cube: cube)
    }

    var view: UIView {
        arView
    }
}

#endif
