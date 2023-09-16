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

    let pointNode: SCNNode

    init(at location: CGPoint, play: Play, result: SCNHitTestResult) {
        self.play = play
        self.startLocation = location
        self.hitNode = result.node
        self.hitCoordinates = result.localCoordinates
        self.hitNormal = result.localNormal

        pointNode = SceneKitUtils.ballArrayNode(direction: hitNormal, length: 1.5, step: 20, color: .purple)
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

    private func beginDragging(at location: CGPoint) -> Dragging? {
        guard let result = hitTest(at: location) else {
            return nil
        }

        return TurnDragging(at: location, play: self, result: result)
    }

    func updateDragging(at location: CGPoint) {
        if let dragging {
            dragging.update(at: location)
            return
        }

        dragging = beginDragging(at: location) ?? VoidDragging()
    }

    func endDragging(at location: CGPoint) {
        dragging?.end(at: location)
        dragging = nil
    }
}
