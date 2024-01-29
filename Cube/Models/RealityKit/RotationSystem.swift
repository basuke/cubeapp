//
//  MoveSystem.swift
//  Cube
//
//  Created by Basuke Suzuki on 10/6/23.
//

import Foundation
import RealityKit
import Combine
import AVKit

fileprivate struct RotationRequest {
    let move: Move
    let duration: Double
    let afterAction: () -> Void
}

class RotationComponent: Component {
    fileprivate var request: RotationRequest?

    init() {
    }

    func apply(move: Move, duration: Double) -> AnyPublisher<Void, Never> {
        precondition(request == nil)

        return Future { promise in
            self.request = RotationRequest(move: move, duration: duration) {
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
}

class RotationSystem: NSObject, System, AVAudioPlayerDelegate {
    static let query = EntityQuery(where: .has(RotationComponent.self))
    var animationCompletion: Cancellable? = nil
    var allPlayers: Set<AVAudioPlayer> = []
    var availablePlayers: Set<AVAudioPlayer> = []

    required init(scene: Scene) {
        super.init()

        for i in 1...7 {
            let player = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "move-\(i)", withExtension: "aiff")!)
            allPlayers.insert(player)
            availablePlayers.insert(player)
        }
    }

    func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.query).forEach { entity in
            guard let component = entity.components[RotationComponent.self] else {
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

        playMoveSound(for: request.move)
    }

    private func playMoveSound(for move: Move) {
        guard !move.isWholeMove,
              let player = availablePlayers.randomElement() else {
            return
        }

        availablePlayers.remove(player)

        player.delegate = self
        player.currentTime = 0
        player.play()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("\(player) did finish playing: successfully: \(flag))")
        availablePlayers.insert(player)
    }
}

extension Axis {
    var vectorf: simd_float3 {
        simd_float3(vector)
    }
}

extension Transform {
    static func turn(move: Move) -> Transform {
        let rotation = simd_quatf(angle: move.angle, axis: move.face.axis.vectorf)
        return Transform(rotation: rotation)
    }
}

extension Entity {
    func apply(move: Move, duration: Double) -> AnyPublisher<Void, Never> {
        guard let component = components[RotationComponent.self] else {
            fatalError("No RotationComponent assigned to the Entity")
        }

        transform = .init()
        return component.apply(move: move, duration: duration)
    }
}
