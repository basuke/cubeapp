//
//  Cube3D.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/14/23.
//

import Foundation
import UIKit
import Combine

enum TurnSpeed {
    case normal
    case quick

    var duration: TimeInterval {
        switch self {
        case .normal: 0.3
        case .quick: 0.1
        }
    }
}

enum ModelKind {
    case sceneKit, realityKit
}

enum CoordinatorKind {
    case sceneKit
    #if !os(xrOS)
    case arKit
    #endif
}

protocol Model {
    func rebuild(with: Cube)
    func run(move: Move, duration: Double) -> Future<Void, Never>
    func setCameraYaw(ratio: Float)
}

protocol Coordinator {
    func hitTest(at: CGPoint, cube: Cube) -> Sticker?
    var view: UIView { get }
    var model: any Model { get }
}

typealias Action = () -> Void

protocol ActionRunner {
    func register(action: @escaping Action)
}

class Play: ObservableObject {
    @Published var cube: Cube = Cube()
    @Published var moves: [Move] = []

    private var models: [ModelKind:Model] = [:]
    private var coordinators: [CoordinatorKind:Coordinator] = [:]

    private var running: AnyCancellable? = nil
    private var requests: [Move] = []

    func rebuild() {
        forEachModel { $0.rebuild(with: cube) }
    }

    func apply(move: Move, speed: TurnSpeed = .normal) {
        guard running == nil else {
            requests.append(move)
            return
        }

        moves.append(move)
        running = run(move: move, speed: speed)
    }

    func undo() {
        if requests.isEmpty {
            if let move = moves.popLast() {
                if running == nil {
                    running = run(move: move.reversed, speed: .quick)
                } else {
                    requests.append(move.reversed)
                }
            }
        } else {
            _ = requests.popLast()
        }
    }

    private func run(move: Move, speed: TurnSpeed) -> AnyCancellable {
        cube = cube.apply(move: move)

        let duration = speed.duration * (debug ? 10.0 : 1.0)
        let futures = models.values.map {
            $0.run(move: move, duration: duration)
        }
        return Publishers.MergeMany(futures)
            .receive(on: DispatchQueue.main)
            .sink { self.afterAction() }
    }

    private func afterAction() {
        running = if requests.isEmpty {
            nil
        } else {
            run(move: requests.removeFirst(), speed: .quick)
        }
    }
}

extension ModelKind {
    func instanciate() -> Model {
        switch self {
        case .sceneKit: SceneKitModel()
        case .realityKit: RealityKitModel()
        }
    }
}

extension Play {
    func model(for kind: ModelKind) -> Model {
        if let model = models[kind] {
            return model
        }

        let model = kind.instanciate()
        model.rebuild(with: cube)

        models[kind] = model
        return model
    }

    func forEachModel(task: (Model) -> Void) {
        models.values.forEach(task)
    }
}

extension CoordinatorKind {
    func instanciate(play: Play) -> Coordinator {
        switch self {
        case .sceneKit: SceneKitCoordinator(model: play.model(for: .sceneKit))
#if !os(xrOS)
        case .arKit: ARKitCoordinator(model: play.model(for: .realityKit))
#endif
        }
    }
}

extension Play {
    func coordinator(for kind: CoordinatorKind) -> Coordinator {
        if let coordinator = coordinators[kind] {
            return coordinator
        }

        let coordinator = kind.instanciate(play: self)

        coordinators[kind] = coordinator
        return coordinator
    }
}

extension Vector {
    // To check the sticker position is on the piece position
    func on(piece: Self) -> Bool {
        func onFace(_ a: Float, _ b: Float) -> Bool {
            a != b && (a * b) > 0
        }

        if piece.x == self.x && piece.y == self.y {
            return onFace(piece.z, self.z)
        }
        if piece.y == self.y && piece.z == self.z {
            return onFace(piece.x, self.x)
        }
        if piece.z == self.z && piece.x == self.x {
            return onFace(piece.y, self.y)
        }
        return false
    }

    var rounded: Self {
        Self(round(x), round(y), round(z))
    }
}

extension Float {
    static func degree(_ value: Self) -> Self {
        .pi * value / 180.0
    }
}
