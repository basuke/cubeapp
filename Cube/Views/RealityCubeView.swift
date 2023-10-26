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
                let angles = value.rotation.eulerAngles(order: .xyz).angles
                let yaw = Rotation3D(angle: .radians(angles.y), axis: .y)
                let pitch = Rotation3D(angle: .radians(angles.x), axis: .x)
                let roll = Rotation3D(angle: .radians(angles.z), axis: .z)
                model.yawEntity.transform.rotation = value.convert(yaw, from: .local, to: .scene)
                model.pitchEntity.transform.rotation = value.convert(pitch, from: .local, to: .scene)
                model.rollEntity.transform.rotation = value.convert(roll, from: .local, to: .scene)
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

            var position = entity.position
            position.z = 0.5
            position.y = -0.5
            entity.position = position

            entity.scale *= 3.0

            content.add(entity)
        }
        .simultaneousGesture(rotationGesture)
        .simultaneousGesture(dragGesture)
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
