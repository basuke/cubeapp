//
//  ImmersiveCubeView.swift
//  Cube
//
//  Created by Basuke Suzuki on 10/26/23.
//

import SwiftUI
import RealityKit
import ARKit
import OSLog

let logger = Logger(subsystem: "com.basuke.Cube", category: "immersive")

#if os(visionOS)

struct ImmersiveCubeView: View {
    @EnvironmentObject private var play: Play
    let scale: Float = 0.02
    @State private var dragging: Dragging?
    @State private var session = ARKitSession()
    @State private var worldInfo = WorldTrackingProvider()
    @State private var translation: Vector = .zero

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

            content.add(entity)
        } update: { context in
            let entity = model.entity
            entity.position = translation.vectorf
        }
        .task {
            do {
                try await self.session.run([self.worldInfo])
            } catch {
                logger.error("Error running World Tracking Provider: \(error.localizedDescription)")
            }

            try! await Task.sleep(for: .seconds(1))
            print(worldInfo.state)
            guard let pose = worldInfo.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else { return }
            let devicePosition = Transform(matrix: pose.originFromAnchorTransform).translation

            translation = Vector(devicePosition) + Vector(0, -0.3, -0.5)
        }
    }
}

#Preview {
    ImmersiveCubeView()
        .environmentObject(Play())
}

#endif
