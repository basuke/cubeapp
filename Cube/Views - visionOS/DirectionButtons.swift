//
//  DirectionButtons.swift
//  Cube
//
//  Created by Basuke Suzuki on 11/29/23.
//

import SwiftUI
import RealityKit

#if os(visionOS)

extension RealityCubeView {
    func identifySticker(from entity: Entity) -> Sticker? {
        guard let color = entity.color else {
            return nil
        }
        return model.identifySticker(from: entity, cube: play.cube, color: color)
    }

    func dismissDirections() {
        model.removeDirectionButtonEntity()
        directionStickerEntity = nil
    }

    private func canInteract(with face: Face) -> Bool {
        if face == .up || face == .front {
            return true
        }
        if face == .back || face == .down {
            return false
        }
        return if right {
            face == .right
        } else {
            face == .left
        }
    }

    var directionButtonsGeasture: some Gesture {
        SpatialEventGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                guard play.playing else {
                    return
                }

                let entity = value.entity
                if let component = entity.components[DirectionComponent.self] {
                    guard let stickerEntity = directionStickerEntity,
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

                    guard let sticker = identifySticker(from: entity) else {
                        return
                    }

                    if canInteract(with: sticker.face) {
                        directionStickerEntity = entity
                        model.showDirections(on: entity, sticker: sticker)
                    }
                }
            }
    }
}

extension RealityKitModel {
    func showDirections(on stickerEntity: Entity, sticker: Sticker) {
        guard stickerEntity.components.has(StickerComponent.self) else {
            fatalError("You can only pass entity for Sticker")
        }

        let materials: [Direction:SimpleMaterial] = [
            .up: SimpleMaterial(color: .lightGray, isMetallic: true),
            .left: SimpleMaterial(color: .gray, isMetallic: true),
            .down: SimpleMaterial(color: .lightGray, isMetallic: true),
            .right: SimpleMaterial(color: .gray, isMetallic: true),
        ]

        func createPartEntity(with mesh: MeshResource, direction: Direction) -> Entity {
            let entity = ModelEntity(mesh: mesh, materials: [materials[direction]!])
            entity.generateCollisionShapes(recursive: false)

            entity.components.set(DirectionComponent(direction))
            entity.components.set(HoverEffectComponent())
            entity.components.set(InputTargetComponent())
            return entity
        }

        func createDirectionEntity(_ direction: Direction) -> Entity {
            let container = Entity()

            let headMesh = MeshResource.generateCone(height: 0.4, radius: 0.4)
            let head = createPartEntity(with: headMesh, direction: direction)
            head.position = [0, 1.1, 0]
            container.addChild(head)

            let poleMesh = MeshResource.generateCylinder(height: 0.4, radius: 0.25)
            let pole = createPartEntity(with: poleMesh, direction: direction)
            pole.position = [0, 0.7, 0]
            container.addChild(pole)

            container.transform.rotation = .init(angle: direction.angle, axis: Axis.z.vectorf)

            return container
        }

        func stickerRotation(_ entity: Entity) -> simd_quatf {
            let direction = entity.convert(normal: [0, 0, 1.0], to: cubeEntity)
            return .init(from: [0, 0, 1.0], to: direction)
        }

        let container = Entity()
        container.scale = [1, 1, 0.7]
        container.position = stickerEntity.convert(position: [0, 0, 0.5], to: cubeEntity)
        container.transform.rotation = stickerRotation(stickerEntity)
        container.components.set(DirectionContainerComponent())

        for direction in Direction.allCases {
            container.addChild(createDirectionEntity(direction))
        }

        cubeEntity.addChild(container)
    }

    func removeDirectionButtonEntity() {
        guard let scene = entity.scene else {
            return
        }

        let query = EntityQuery(where: .has(DirectionContainerComponent.self))
        scene.performQuery(query).forEach { container in
            container.removeFromParent()
        }
    }
}

struct DirectionComponent: Component, Codable {
    let direction: Direction

    init(_ direction: Direction) {
        self.direction = direction
    }
}

struct DirectionContainerComponent: Component, Codable {
}

#endif
