//
//  RealityCubeView.swift
//  Cube
//
//  Created by Basuke Suzuki on 10/9/23.
//

import SwiftUI
import RealityKit

#if os(visionOS)

struct RealityCubeView: View {
    @ObservedObject var play: Play

    var body: some View {
        RealityView { content in
            if let model = play.model as? RealityKitModel {
                content.add(model.entity)
            }
        }
    }
}

let kScaleForRealityKit: Float = 0.05

extension RealityKitModel {
    var entity: Entity {
        let adjustEntity = Entity()
        adjustEntity.addChild(yawEntity)
        adjustEntity.position = simd_float3(0, 0, 0)
        adjustEntity.scale = simd_float3(kScaleForRealityKit, kScaleForRealityKit, kScaleForRealityKit)
        return adjustEntity
    }
}

#Preview {
    RealityCubeView(play: Play())
}

#endif
