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
    func findStickerEntityIncludingParents(from entity: Entity) -> Entity? {
        if entity.components[StickerComponent.self] != nil {
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

    func dismissDirections() {
        if let stickerEntity = directionStickerEntity {
            model.dismissDirections(on: stickerEntity)
        }
    }

    var directionButtonsGeasture: some Gesture {
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
}

extension RealityKitModel {
    func showDirections(on stickerEntity: Entity) {
        let materials: [Direction:SimpleMaterial] = [
            .up: SimpleMaterial(color: .yellow, isMetallic: false),
            .left: SimpleMaterial(color: .systemPink, isMetallic: false),
            .down: SimpleMaterial(color: .systemGreen, isMetallic: false),
            .right: SimpleMaterial(color: .red, isMetallic: false),
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
            head.position = [0, 1.1, 0.5]
            container.addChild(head)

            let poleMesh = MeshResource.generateCylinder(height: 0.4, radius: 0.3)
            let pole = createPartEntity(with: poleMesh, direction: direction)
            pole.position = [0, 0.7, 0.5]
            container.addChild(pole)

            container.transform.rotation = .init(angle: direction.angle, axis: Axis.z.vectorf)

            return container
        }

        for direction in Direction.allCases {
            stickerEntity.addChild(createDirectionEntity(direction))
        }
    }

    func dismissDirections(on stickerEntity: Entity) {
        let entities = stickerEntity.children.map { $0 }
        entities.forEach { $0.removeFromParent() }
    }
}

struct DirectionComponent: Component, Codable {
    let direction: Direction

    init(_ direction: Direction) {
        self.direction = direction
    }
}

#endif
