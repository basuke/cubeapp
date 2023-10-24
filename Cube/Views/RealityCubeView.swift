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
    @State private var dragging: Dragging3D?

    func beginDragging(at location3D: Point3D, entity: Entity) -> Dragging3D? {
        guard let model = play.model(for: .realityKit) as? RealityKitModel,
              let component = entity.components[StickerComponent.self] as StickerComponent?,
              let sticker = model.identifySticker(from: entity, cube: play.cube, color: component.color) else {
            return nil
        }

        return TurnDragging3D(at: location3D, play: play, sticker: sticker)
    }

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .targetedToAnyEntity()
            .onChanged { value in
                let location = Point3D(value.convert(value.location3D, from: .local, to: .scene))
                guard let dragging else {
                    dragging = beginDragging(at: location, entity: value.entity) ?? VoidDragging()
                    return
                }

                dragging.update(location3D: location)
            }
            .onEnded { value in
                let location = Point3D(value.convert(value.location3D, from: .local, to: .scene))
                dragging?.end(location3D: location)
                dragging = nil
            }
    }

    var body: some View {
        RealityView { content in
            guard let model = play.model(for: .realityKit) as? RealityKitModel else {
                fatalError("Cannot get RealityKitModel")
            }

            let entity = model.entity

            if debug {
                let material = SimpleMaterial(color: .blue, isMetallic: true)
                let sphere = ModelEntity(mesh: MeshResource.generateSphere(radius: 1.5 * sqrtf(3.0)), materials: [material])
                sphere.components.set(OpacityComponent(opacity: 0.2))
                entity.addChild(sphere)
            }

            var position = entity.position
            position.z = 0.5
            position.y = -0.5
            entity.position = position

            entity.scale *= 4.6

            content.add(entity)
        }
        .gesture(dragGesture)
    }
}

let kScaleForRealityKit: Float = 0.02

extension RealityKitModel {
    var entity: Entity {
        entity(scale: kScaleForRealityKit)
    }

    func entity(scale: Float) -> Entity {
        let adjustEntity = Entity()
        adjustEntity.addChild(yawEntity)
        adjustEntity.position = simd_float3(0, 0, 0)
        adjustEntity.scale = simd_float3(kScaleForRealityKit, kScaleForRealityKit, kScaleForRealityKit)
        return adjustEntity
    }
}

#Preview {
    RealityCubeView()
        .environmentObject(Play())
}

#endif
