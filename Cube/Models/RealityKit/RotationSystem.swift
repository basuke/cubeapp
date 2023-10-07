//
//  MoveSystem.swift
//  Cube
//
//  Created by Basuke Suzuki on 10/6/23.
//

import Foundation
import RealityKit
import Combine

fileprivate struct RotationRequest {
    let move: Move
    let duration: Double
    let afterAction: () -> Void
}

class RotationComponent: Component {
    fileprivate var request: RotationRequest?

    init() {
    }

    func apply(move: Move, duration: Double) -> Future<Void, Never> {
        precondition(request == nil)

        return Future { promise in
            self.request = RotationRequest(move: move, duration: duration) {
                promise(.success(()))
            }
        }
    }
}

class RotationSystem: System {
    static let query = EntityQuery(where: .has(RotationComponent.self))
    var animationCompletion: Cancellable? = nil

    required init(scene: Scene) {
    }

    func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.query).forEach { entity in
            guard let component = entity.components[RotationComponent.self] as? RotationComponent else {
                return
            }

            if let request = component.request {
                run(scene: context.scene, entity: entity, request: request)
                component.request = nil
            }
        }
    }

    private func run(scene: Scene, entity: Entity, request: RotationRequest) {
        entity.transform = .init()

        let transform: Transform = .turn(move: request.move)

        let controller = entity.move(to: transform, relativeTo: entity.parent, duration: request.duration, timingFunction: .easeOut)

        animationCompletion = scene.publisher(for: AnimationEvents.PlaybackCompleted.self)
            .filter { $0.playbackController == controller }
            .sink { _ in
                self.animationCompletion = nil

                request.afterAction()
            }
    }
}

extension Transform {
    static func turn(move: Move) -> Transform {
        let rotation = simd_quatf(angle: move.angle, axis: simd_normalize(move.face.axis.simd3))
        return Transform(rotation: rotation)
    }
}

extension Entity {
    func apply(move: Move, duration: Double) -> Future<Void, Never> {
        guard let component = components[RotationComponent.self] as? RotationComponent else {
            fatalError("No RotationComponent assigned to the Entity")
        }

        transform = .init()
        return component.apply(move: move, duration: duration)
    }
}
