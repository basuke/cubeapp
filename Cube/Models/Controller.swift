//
//  Controller.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/25/23.
//

import Foundation
import SceneKit

extension Play {
    func setupController() {
        func addButtonNode(label: String, x: Float, y: Float) {
            let button = ButtonNode(label: label) {
                guard let move = Move.from(string: label) else {
                    return
                }

                self.apply(move: move)

                if label == "y" || label == "z'" {
                    self.camera(from: .right)
                } else if label == "y'" || label == "z" {
                    self.camera(from: .left)
                }
            }
            button.position = SCNVector3(x, y, 0)
            self.controllerNode.addChildNode(button)
        }

        addButtonNode(label: "x", x: 0, y: 3.0)
        addButtonNode(label: "x'", x: 0, y: -3.0)

        addButtonNode(label: "y", x: -2.2, y: -2.0)
        addButtonNode(label: "y'", x: 2.2, y: -2.0)

        addButtonNode(label: "z", x: 2.2, y: 2.0)
        addButtonNode(label: "z'", x: -2.2, y: 2.0)

        self.scene.rootNode.addChildNode(controllerNode)
    }
}
