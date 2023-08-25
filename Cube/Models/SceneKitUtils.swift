//
//  SceneKitUtils.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/24/23.
//

import Foundation
import SceneKit

struct SceneKitUtils {
    static func ball(radius: CGFloat, color: UIColor = .gray) -> SCNGeometry {
        let ball = SCNSphere(radius: radius)
        ball.firstMaterial?.diffuse.contents = color
        return ball
    }

    static func ballArrayNode(direction: SCNVector3, length: Double = 1.0, step: Int = 10, radius: CGFloat = 0.05, color: UIColor = .gray) -> SCNNode {
        precondition(step > 0)

        let node = SCNNode()

        let ball = ball(radius: radius, color: color)

        func createBall(_ ratio: Float) -> SCNNode {
            return node
        }

        for ratio in stride(from: 0.0, through: 1.0, by: 1.0 / Double(step)) {
            let ballNode = SCNNode(geometry: ball)
            ballNode.opacity = CGFloat(1.0 - ratio)
            ballNode.position = direction * (length * ratio)
            node.addChildNode(ballNode)
        }

        return node
    }
}

extension SCNVector3 {
    init(_ vec: Vector) {
        self.init(vec.x, vec.y, vec.z)
    }

    static func *(vec: Self, scale: Double) -> Self {
        let scale = Float(scale)
        return SCNVector3(vec.x * scale, vec.y * scale, vec.z * scale)
    }
}

extension Vector {
    init(_ vec: SCNVector3) {
        self.init(vec.x, vec.y, vec.z)
    }
}
