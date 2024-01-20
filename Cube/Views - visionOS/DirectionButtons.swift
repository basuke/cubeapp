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
        if let stickerEntity = directionStickerEntity {
            model.dismissDirections(on: stickerEntity)
            directionStickerEntity = nil
        }
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

        func createDirectionEntity(_ direction: Direction, _ transform: simd_quatf) -> Entity {
            let container = Entity()

            let headMesh = MeshResource.generateCone(height: 0.4, radius: 0.4)
            let head = createPartEntity(with: headMesh, direction: direction)
            head.scale = [1, 1, 0.3]
            head.position = [0, 1.1, 0.5]
            container.addChild(head)

            let poleMesh = MeshResource.generateCylinder(height: 0.4, radius: 0.25)
            let pole = createPartEntity(with: poleMesh, direction: direction)
            pole.scale = [1, 1, 0.2]
            pole.position = [0, 0.7, 0.5]
            container.addChild(pole)

            container.transform.rotation = simd_mul(.init(angle: direction.angle, axis: Axis.z.vectorf), transform)

            return container
        }

        func correctionTransform(upAxis: Axis, rotationAxis: Axis) -> simd_quatf {
            let upAxisVector = upAxis.vectorf
            let rotationAxisVector = rotationAxis.vectorf

            let up = stickerEntity.convert(position: upAxisVector, from: cubeEntity)
            let origin = stickerEntity.convert(position: .zero, from: cubeEntity)
            let localUpVector = Vector(up - origin).rounded.vectorf

            if localUpVector == upAxisVector {
                return .init(angle: 0, axis: rotationAxisVector)
            } else if localUpVector == (-upAxis).vectorf {
                return .init(angle: .pi, axis: rotationAxisVector)
            } else {
                return simd_quatf(from: upAxisVector, to: localUpVector)
            }
        }

        let transform = if sticker.face == .up {
//            simd_quatf.init(angle: 0, axis: Axis.y.vectorf)
            correctionTransform(upAxis: -Axis.z, rotationAxis: Axis.z)
        } else {
            correctionTransform(upAxis: Axis.y, rotationAxis: Axis.z)
        }

        for direction in Direction.allCases {
            stickerEntity.addChild(createDirectionEntity(direction, transform))
        }
    }

    func dismissDirections(on stickerEntity: Entity) {
        let entities = stickerEntity.children.map { $0 }
        entities.forEach { $0.removeFromParent() }
    }

    func dismissDirections() {
        guard let scene = entity.scene else {
            return
        }

        let query = EntityQuery(where: .has(StickerComponent.self))
        scene.performQuery(query).forEach { stickerEntity in
            dismissDirections(on: stickerEntity)
        }
    }
}

struct DirectionComponent: Component, Codable {
    let direction: Direction

    init(_ direction: Direction) {
        self.direction = direction
    }
}

#endif
