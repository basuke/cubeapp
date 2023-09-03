//
//  Camera.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/25/23.
//

import Foundation
import SceneKit

let initialPitch = Float.degree(45)
let initialYaw = Float.degree(-12)
let cameraDistance: Float = 34
let cameraFOV: CGFloat = 8

extension Play {
    func setupCamera() {
        // Add the box node to the scene
        pitchNode.addChildNode(cubeNode)
        yawNode.addChildNode(pitchNode)
        scene.rootNode.addChildNode(yawNode)

        pitchNode.eulerAngles = SCNVector3(initialPitch, 0.0, 0.0)
        yawNode.eulerAngles = SCNVector3(0.0, initialYaw, 0.0)

        let camera = SCNCamera()
        camera.fieldOfView = cameraFOV
        camera.projectionDirection = .horizontal

        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, cameraDistance)
        cameraNode.constraints = [SCNLookAtConstraint(target: cubeNode)]
        scene.rootNode.addChildNode(cameraNode)
    }

    func positionCamera(to direction: Direction) {

        switch direction {
        case .left, .right:
            SCNTransaction.animationDuration = 0.1
            let angle = (direction == .left ? -1 : 1) * initialYaw * 2
            yawNode.eulerAngles = SCNVector3(0.0, angle, 0.0)
        case .up, .down:
            SCNTransaction.animationDuration = 0.2
            let angle = initialPitch + (direction == .down ? -1 : 1) * .pi / 2 * 0.8
            pitchNode.eulerAngles = SCNVector3(angle, 0.0, 0.0)
        }
    }

    func resetCamera() {
        SCNTransaction.animationDuration = 0.3
        pitchNode.eulerAngles = SCNVector3(initialPitch, 0.0, 0.0)

        let angle = yawNode.eulerAngles.y < 0 ? initialYaw : -initialYaw
        yawNode.eulerAngles = SCNVector3(0.0, angle, 0.0)
    }
}
