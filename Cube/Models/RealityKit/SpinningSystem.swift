//
//  SpinningSystem.swift
//  Cube
//
//  Created by Basuke Suzuki on 1/22/24.
//


import Foundation
import RealityKit
import Combine

class SpinningComponent: Component {
    enum State {
        case idle, startRequested, spinning, stopRequested
    }

    var state: State = .idle
    var animationCompletion: Cancellable? = nil

    let yAxis: simd_float3 = [0, 1, 0]

    func run(scene: Scene, entity: Entity) {
        if state == .startRequested {
            animationCompletion = nil
            spin(scene: scene, entity: entity, easeIn: true)
            state = .spinning
        } else if state == .spinning && animationCompletion == nil {
            spin(scene: scene, entity: entity, easeIn: false)
        } else if state == .stopRequested {
            animationCompletion = nil
            reset(scene: scene, entity: entity)
            state = .idle
        }
    }

    private func spin(scene: Scene, entity: Entity, easeIn: Bool = false) {
        let angle = Float.pi / 8

        var transform = entity.transform
        transform.rotation = simd_mul(.init(angle: angle, axis: yAxis), transform.rotation)

        let controller = entity.move(to: transform, relativeTo: entity.parent, duration: 1.0, timingFunction: easeIn ? .easeIn : .linear)
        animationCompletion = scene.publisher(for: AnimationEvents.PlaybackCompleted.self)
            .filter { $0.playbackController == controller }
            .sink { _ in
                self.animationCompletion = nil
            }
    }

    private func reset(scene: Scene, entity: Entity) {
        var transform = entity.transform
        transform.rotation = .init(angle: 0, axis: yAxis)

        let controller = entity.move(to: transform, relativeTo: entity.parent, duration: 1.0, timingFunction: .easeInOut)
        animationCompletion = scene.publisher(for: AnimationEvents.PlaybackCompleted.self)
            .filter { $0.playbackController == controller }
            .sink { _ in
                self.animationCompletion = nil
            }
    }
}

extension Entity {
    func startSpin() {
        components[SpinningComponent.self]?.state = .startRequested
    }

    func stopSpin() {
        components[SpinningComponent.self]?.state = .stopRequested
    }
}

class SpinningSystem: System {
    static let query = EntityQuery(where: .has(SpinningComponent.self))

    required init(scene: Scene) {
    }

    func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.query).forEach { entity in
            guard let component = entity.components[SpinningComponent.self] else {
                return
            }

            component.run(scene: context.scene, entity: entity)
        }
    }
}
