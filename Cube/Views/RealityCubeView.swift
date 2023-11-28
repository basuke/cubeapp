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
#if targetEnvironment(simulator)
    let scale: Float = 0.06
#else
    let scale: Float = 0.04
#endif
    @State private var dragging: Dragging?
    @State private var directionStickerEntity: Entity?
    @State private var lookDirection: Direction?

    var model: RealityKitModel {
        guard let model = play.model(for: .realityKit) as? RealityKitModel else {
            fatalError("Cannot get RealityKitModel")
        }
        return model
    }

    func findStickerEntityIncludingParents(from entity: Entity) -> Entity? {
        if let component = entity.components[StickerComponent.self] as StickerComponent? {
            return entity
        }
        if let parent = entity.parent {
            return self.findStickerEntityIncludingParents(from: parent)
        }
        return nil
    }

    func identifySticker(from entity: Entity) -> Sticker? {
        guard let stickerEntity = findStickerEntityIncludingParents(from: entity),
              let color = entity.color else {
            return nil
        }
        return model.identifySticker(from: stickerEntity, cube: play.cube, color: color)
    }

    func beginDragging(at location: CGPoint, entity: Entity) -> Dragging? {
        guard let sticker = identifySticker(from: entity) else {
            return nil
        }

        return TurnDragging(at: location, play: play, sticker: sticker)
    }

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .targetedToAnyEntity()
            .onChanged { value in
                guard let dragging else {
                    dismissDirections();

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
                dismissDirections();

                let (swing, twist) = value.rotation.swingTwist(twistAxis: .y)
                model.yawEntity.transform.rotation = value.convert(twist, from: .local, to: .scene)
                model.pitchEntity.transform.rotation = value.convert(swing, from: .local, to: .scene)
            }
    }

    func dismissDirections() {
        if let stickerEntity = directionStickerEntity {
            model.dismissDirections(on: stickerEntity)
        }
    }

    var tapGesture: some Gesture {
        SpatialEventGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                let entity = value.entity
                if let component = entity.components[DirectionComponent.self] {
                    guard let stickerEntity = findStickerEntityIncludingParents(from: entity),
                          let sticker = identifySticker(from: stickerEntity),
                          let moveStr = sticker.identifyMove(for: component.direction),
                          let move = Move.from(string: moveStr) else {
                        dismissDirections();
                        return
                    }

                    dismissDirections();
                    play.apply(move: move)
                } else {
                    dismissDirections();
                    model.showDirections(on: entity)
                    directionStickerEntity = entity
                }
            }
    }

    var body: some View {
        ZStack {
            ControllerView(lookDirection: $lookDirection) {
                dismissDirections()
            }
            RealityView { content in
                let entity = model.entity

                let material = SimpleMaterial(color: .blue, isMetallic: true)
                let sphere = ModelEntity(mesh: MeshResource.generateSphere(radius: 1.5 * sqrtf(3.0)), materials: [material])
                entity.addChild(sphere)

                if debug {
                    sphere.components.set(OpacityComponent(opacity: 0.2))
                } else {
                    sphere.components.set(OpacityComponent(opacity: 0))
                }
            } update: { content in
                if !play.inImmersiveSpace && !play.inWindow {
                    let entity = model.entity

                    entity.transform = Transform(scale: [scale, scale, scale])
                    model.pitch = .pi / 4
                    model.yaw = -.pi / 8

                    content.add(entity)
                    play.inWindow = true
                }

                model.updateCamera(direction: lookDirection)
            }
            .simultaneousGesture(tapGesture)
        }
        .frame(width: 560, height: 560)
    }
}

#Preview {
    RealityCubeView()
        .environmentObject(Play())
}

#endif
