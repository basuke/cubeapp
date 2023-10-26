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

    func beginDragging(at location: CGPoint, entity: Entity) -> Dragging? {
        guard let component = entity.components[StickerComponent.self] as StickerComponent?,
              let sticker = model.identifySticker(from: entity, cube: play.cube, color: component.color) else {
            return nil
        }

        return TurnDragging(at: location, play: play, sticker: sticker)
    }

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .targetedToAnyEntity()
            .onChanged { value in
                guard let dragging else {
                    dragging = beginDragging(at: value.location, entity: value.entity) ?? VoidDragging()
                    return
                }

                dragging.update(at: value.location)
            }
            .onEnded { value in
                dragging?.end(at: value.location)
                dragging = nil
            }
    }

    var rotationGesture: some Gesture {
        RotateGesture3D()
            .targetedToAnyEntity()
            .onChanged { value in
                let (swing, twist) = value.rotation.swingTwist(twistAxis: .y)
                model.yawEntity.transform.rotation = value.convert(twist, from: .local, to: .scene)
                model.pitchEntity.transform.rotation = value.convert(swing, from: .local, to: .scene)
            }
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
        } update: { content in
            if !play.inImmersiveSpace {
                let entity = model.entity

                entity.scale = simd_float3(scale, scale, scale)
                entity.position = translation.vectorf

                content.add(entity)
            }
        }
        .simultaneousGesture(rotationGesture)
        .simultaneousGesture(dragGesture)
    }
}

#Preview {
    RealityCubeView(scale: 0.02, translation: .zero)
        .environmentObject(Play())
}

#endif
