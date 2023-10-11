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
    @State private var dragging: Dragging?

    func beginDragging(at location: CGPoint, entity: Entity) -> Dragging? {
        guard let model = play.model(for: .realityKit) as? RealityKitModel,
              let component = entity.components[StickerComponent.self] as StickerComponent?,
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

    var body: some View {
        RealityView { content in
            guard let model = play.model(for: .realityKit) as? RealityKitModel else {
                fatalError("Cannot get RealityKitModel")
            }

            content.add(model.entity)
        }
        .gesture(dragGesture)
    }
}

let kScaleForRealityKit: Float = 0.02

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
