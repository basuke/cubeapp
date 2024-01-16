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
    @EnvironmentObject var play: Play
#if targetEnvironment(simulator)
    let scale: Float = 0.05
#else
    let scale: Float = 0.05
#endif
    @State var directionStickerEntity: Entity?
    @State var lookDirection: Direction?

    var model: RealityKitModel {
        guard let model = play.model(for: .realityKit) as? RealityKitModel else {
            fatalError("Cannot get RealityKitModel")
        }
        return model
    }

    var body: some View {
        HStack {
            VStack {
                CommandView()
            }
            .frame(width: 320)
            ZStack {
                CancelView {
                    dismissDirections()
                }
                ControllerView(lookDirection: $lookDirection)
                RealityView { content in
                    let entity = model.entity

                    entity.transform = Transform(scale: [scale, scale, scale])
                    model.pitch = .pi / 4 - (.pi / 10)
                    model.yaw = -.pi / 8

                    content.add(entity)

                    let material = SimpleMaterial(color: .blue, isMetallic: true)
                    let sphere = ModelEntity(mesh: MeshResource.generateSphere(radius: 1.5 * sqrtf(3.0)), materials: [material])
                    entity.addChild(sphere)

                    if debug {
                        sphere.components.set(OpacityComponent(opacity: 0.2))
                    } else {
                        sphere.components.set(OpacityComponent(opacity: 0))
                    }
                } update: { content in
                    model.updateCamera(direction: lookDirection)
                }
                .simultaneousGesture(directionButtonsGeasture)
            }
            .frame(width: 560, height: 560)
            VStack {
                HistoryView()
                    .padding()
            }
            .frame(width: 320)
        }
//        .ornament(attachmentAnchor: .scene(.bottom), contentAlignment: .center) {
//            OrnamentView()
//            .glassBackgroundEffect(in: .capsule(style: .continuous))
//        }
    }
}

#Preview {
    RealityCubeView()
        .environmentObject(Play())
}

#endif
