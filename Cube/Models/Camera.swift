//
//  Camera.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/25/23.
//

import Foundation
import SceneKit
import RealityKit

let initialPitch = Float.degree(45)
let initialYaw = Float.degree(-12)
let cameraDistance: Float = 34
let cameraFOV: CGFloat = 8

extension SceneKitModel {
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

    func setCameraYaw(ratio: Float) {
        let yaw = initialYaw * ratio
        yawNode.eulerAngles = SCNVector3(0.0, yaw, 0.0)
    }
}

let kYawScaleFactorForARKit: Float = 1.7
let kDistanceForARKit: Float = 0.3
let kScaleForARKit: Float = 0.4

extension RealityKitModel {
#if !os(visionOS)
    func setupCamera(scene: Scene) {
        pitchEntity.transform = Transform(pitch: initialPitch, yaw: 0.0, roll: 0.0)
        yawEntity.transform = Transform(pitch: 0.0, yaw: initialYaw * kYawScaleFactorForARKit, roll: 0.0)

        let adjustEntity = Entity()
        adjustEntity.addChild(yawEntity)
        adjustEntity.position = simd_float3(0, 0, -kDistanceForARKit)
        adjustEntity.scale = simd_float3(kScaleForARKit, kScaleForARKit, kScaleForARKit)
        cameraAnchor.addChild(adjustEntity)

        scene.anchors.append(cameraAnchor)
    }
#endif

    func setCameraYaw(ratio: Float) {
        let yaw = initialYaw * ratio
        yawEntity.transform = Transform(pitch: 0.0, yaw: yaw * kYawScaleFactorForARKit, roll: 0.0)
    }
}
