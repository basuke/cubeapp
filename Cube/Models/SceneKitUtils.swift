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

class ButtonNode: SCNNode {
    let action: () -> Void

    init(label: String, action: @escaping () -> Void) {
        self.action = action

        super.init()

        let text = SCNText(string: label, extrusionDepth: 0.24)

        let textNode = SCNNode(geometry: text)
        let min = text.boundingBox.min
        let max = text.boundingBox.max
        let dx = (max.x - min.x) / 2
        let dy = (max.y - min.y) / 2
        let scale = Float(1.0) / 12 * 0.9
        textNode.scale = SCNVector3(scale, scale, 1.0)
        textNode.position = SCNVector3(-(dx + min.x) * scale, -(dy + min.y) * scale, 0.0)

        let base = SCNCylinder(radius: 0.5, height: 0.2)
        base.firstMaterial?.diffuse.contents = UIColor.darkGray
        let baseNode = SCNNode(geometry: base)

        // Because circle is facing up by default,
        // we need to rotate the node by 90 degrees around X axis
        baseNode.eulerAngles = SCNVector3(.degree(90), 0, 0)

        addChildNode(textNode)
        addChildNode(baseNode)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
