//
//  Drag.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/22/23.
//

import Foundation
import SceneKit

protocol Dragging {
    func update(at location: CGPoint)
    func end(at location: CGPoint)
}

class TurnDragging: Dragging {
    let play: Play
    let startLocation: CGPoint
    let hitNode: SCNNode
    let hitCoordinates: SCNVector3
    let hitNormal: SCNVector3

    let pointNode = SCNNode()

    init(at location: CGPoint, play: Play, result: SCNHitTestResult) {
        self.play = play
        self.startLocation = location
        self.hitNode = result.node
        self.hitCoordinates = result.localCoordinates
        self.hitNormal = result.localNormal

        let ball = SCNSphere(radius: 0.05)
        ball.firstMaterial?.diffuse.contents = UIColor.purple
        let length: Float = 1.5

        func createBall(_ ratio: Float) -> SCNNode {
            let node = SCNNode(geometry: ball)
            node.opacity = CGFloat(1.0 - ratio)
            node.position = SCNVector3(
                hitNormal.x * length * ratio,
                hitNormal.y * length * ratio,
                hitNormal.z * length * ratio
            )
            return node
        }

        for ratio in stride(from: 0.0, through: 1.0, by: 0.05) {
            pointNode.addChildNode(createBall(Float(ratio)))
        }

        pointNode.position = hitCoordinates
        hitNode.addChildNode(pointNode)

        print("begin at \(self.hitNormal)")
    }

    func update(at location: CGPoint) {
        print("update at \(location)")
    }

    func end(at location: CGPoint) {
        pointNode.removeFromParentNode()

        print("end at \(location)")
    }
}

class VoidDragging: Dragging {
    init() {
    }

    func update(at location: CGPoint) {
    }

    func end(at location: CGPoint) {
    }
}

extension Play {
    func hitTest(at location: CGPoint) -> SCNHitTestResult? {
        let options: [SCNHitTestOption : Any] = [
            .searchMode: SCNHitTestSearchMode.closest.rawValue,
        ]

        return view.hitTest(location, options: options).first
    }

    func updateDragging(at location: CGPoint) {
        if let dragging {
            dragging.update(at: location)
            return
        }

        guard let result = hitTest(at: location) else {
            dragging = VoidDragging()
            return
        }

        dragging = TurnDragging(at: location, play: self, result: result)
    }

    func endDragging(at location: CGPoint) {
        dragging?.end(at: location)
        dragging = nil
    }
}
