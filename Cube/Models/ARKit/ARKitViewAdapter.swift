//
//  ARKitViewAdapter.swift
//  Cube
//
//  Created by Basuke Suzuki on 10/9/23.
//

import Foundation
import RealityKit
import UIKit

#if !os(visionOS)

let kDistanceForARKit: Float = 0.3
let kScaleForARKit: Float = 0.4

class ARKitViewAdapter: ViewAdapter {
    let model: RealityKitModel
    let arView = ARView(frame: .zero)
    let cameraAnchor = AnchorEntity()

    required init(model: Model) {
        guard let model = model as? RealityKitModel else {
            fatalError("Requires RealityKitModel")
        }

        self.model = model

        adjustCamera()
        arView.scene.anchors.append(cameraAnchor)
    }

    private func adjustCamera() {
        let adjustEntity = Entity()
        adjustEntity.addChild(model.yawEntity)
        adjustEntity.position = simd_float3(0, 0, -kDistanceForARKit)
        adjustEntity.scale = simd_float3(kScaleForARKit, kScaleForARKit, kScaleForARKit)
        cameraAnchor.addChild(adjustEntity)
    }

    func hitTest(at location: CGPoint, cube: Cube) -> Sticker? {
        guard let result = arView.hitTest(location, query: .nearest).first else {
            return nil
        }

        guard let component = result.entity.components[StickerComponent.self] as StickerComponent? else {
            return nil
        }

        return model.identifySticker(from: result.entity, cube: cube, color: component.color)
    }
    var view: UIView {
        arView
    }
}

#endif
