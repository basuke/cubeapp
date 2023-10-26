//
//  ImmersiveCubeView.swift
//  Cube
//
//  Created by Basuke Suzuki on 10/26/23.
//

import SwiftUI
import RealityKit

#if os(visionOS)

struct ImmersiveCubeView: View {
    @EnvironmentObject private var play: Play
    let scale: Float
    let translation: Vector
    @State private var dragging: Dragging?

    var model: RealityKitModel {
        guard let model = play.model(for: .realityKit) as? RealityKitModel else {
            fatalError("Cannot get RealityKitModel")
        }
        return model
    }

    var body: some View {
        RealityView { content in
            let entity = model.entity

            if debug {
                let material = SimpleMaterial(color: .blue, isMetallic: true)
                let sphere = ModelEntity(mesh: MeshResource.generateSphere(radius: 1.5 * sqrtf(3.0)), materials: [material])
                sphere.components.set(OpacityComponent(opacity: 0.2))
                entity.addChild(sphere)
            }

            entity.scale = simd_float3(scale, scale, scale)
            entity.position = translation.vectorf

            content.add(entity)
        }
    }
}

#Preview {
    ImmersiveCubeView(scale: 0.02, translation: .zero)
        .environmentObject(Play())
}

#endif
