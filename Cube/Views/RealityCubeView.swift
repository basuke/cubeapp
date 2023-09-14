//
//  RealityCubeView.swift
//  Cube
//
//  Created by Basuke Suzuki on 9/8/23.
//

import SwiftUI
import SceneKit
import RealityKit
import Combine

#if os(xrOS)

struct RealityCubeView: View {
    @ObservedObject var play: Play
    @State private var yawRatio: Float = 0.0
    @State private var dragging: Dragging?

    class RealityViewActionRunner: ActionRunner {
        var subscription: EventSubscription? = nil
        var action: Action? = nil

        init(content: RealityViewContent) {
            subscription = content.subscribe(to: AnimationEvents.PlaybackCompleted.self) { _ in
                guard let action = self.action else { return }
                action()
            }
        }

        func register(action: @escaping Action) {
            self.action = action
        }
    }

    func beginDragging(at location: CGPoint, entity: Entity) -> Dragging? {
        guard let model = play.model(for: .realityKit) as? RealityKitModel else {
            return nil
        }

        guard let sticker = model.identifySticker(from: entity, cube: play.cube) else {
            return nil
        }

        return TurnDragging(at: location, sticker: sticker) { move in
            play.apply(move: move, speed: .quick)
        }
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
            if let model = play.model(for: .realityKit) as? RealityKitModel {
                if model.runner == nil {
                    model.runner = RealityViewActionRunner(content: content)
                }

                content.add(model.entity)
            }
        } update: { content in
            play.forEachModel { $0.setCameraYaw(ratio: -yawRatio) }
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

#endif
