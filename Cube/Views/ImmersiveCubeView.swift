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
    let scale: Float = 0.02
    let translation: Vector = .zero
    @State private var dragging: Dragging?
    @State private var tracker = HandTracking()

    var model: RealityKitModel {
        guard let model = play.model(for: .realityKit) as? RealityKitModel else {
            fatalError("Cannot get RealityKitModel")
        }
        return model
    }

    var body: some View {
        RealityView { content in
            let entity = model.entity

            entity.scale = simd_float3(scale, scale, scale)
            entity.position = translation.vectorf

            content.add(entity)
        }
        .onAppear() {
            Task {
                await tracker.start()
            }
        }
    }
}

#Preview {
    ImmersiveCubeView()
        .environmentObject(Play())
}

#endif
