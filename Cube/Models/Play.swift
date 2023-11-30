//
//  Cube3D.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/14/23.
//

import Foundation
import UIKit
import Combine
import Spatial

enum TurnSpeed: TimeInterval, RawRepresentable {
    case normal = 0.3
    case quick = 0.1

    var duration: TimeInterval {
        self.rawValue * (debug ? 10.0 : 1.0)
    }
}

enum ModelKind {
    case sceneKit, realityKit
}

enum ViewAdapterKind {
    case sceneKit
#if !os(visionOS)
    case arKit
#endif
}

protocol Model {
    func rebuild(with: Cube)
    func run(move: Move, duration: Double) -> AnyPublisher<Void, Never>
    func setCameraYaw(ratio: Float)
}

protocol ViewAdapter {
    init(model: Model)
    func hitTest(at: CGPoint, cube: Cube) -> Sticker?
    var view: UIView { get }
}

class Play: ObservableObject {
    @Published var cube: Cube = Cube_TestData.turnedCube
    @Published var moves: [Move] = []
    @Published var undoneMoves: [Move] = []
#if os(visionOS)
    @Published var inWindow: Bool = false
    @Published var inImmersiveSpace: Bool = false
#endif

    private var models: [ModelKind:Model] = [:]
    private var viewAdapters: [ViewAdapterKind:ViewAdapter] = [:]

    var requests: [Move] = []
    var running: AnyCancellable?

    func rebuild() {
        models.values.forEach { $0.rebuild(with: cube) }
    }

    func apply(move: Move, speed: TurnSpeed = .normal) {
        guard running == nil else {
            requests.append(move)
            return
        }

        moves.append(move)
        running = run(move: move, speed: speed)
    }

    func undo(speed: TurnSpeed = .quick) {
        if requests.isEmpty {
            if let move = moves.popLast()?.reversed {
                if running != nil {
                    requests.append(move)
                } else {
                    running = run(move: move, speed: speed)
                }
            }
        } else {
            _ = requests.popLast()
        }
    }

    var canUndo: Bool {
        !moves.isEmpty
    }

    func redo(speed: TurnSpeed = .quick) {
    }

    var canRedo: Bool {
        false
    }

    private func run(move: Move, speed: TurnSpeed) -> AnyCancellable {
        cube = cube.apply(move: move)

        let results = models.values.map { $0.run(move: move, duration: speed.duration) }
        return Publishers.MergeMany(results)
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
    func instantiate() -> Model {
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
        } else {
            let model = kind.instantiate()
            model.rebuild(with: cube)
            models[kind] = model
            return model
        }
    }

    func forEachModel(callback: (Model) -> Void) {
        models.values.forEach { callback($0) }
    }
}

extension ViewAdapterKind {
    func instantiate(play: Play) -> ViewAdapter {
        switch self {
        case .sceneKit: SceneKitViewAdapter(model: play.model(for: .sceneKit))
#if !os(visionOS)
        case .arKit: ARKitViewAdapter(model: play.model(for: .realityKit))
#endif
        }
    }
}

extension Play {
    func viewAdapter(for kind: ViewAdapterKind) -> ViewAdapter {
        if let viewAdapter = viewAdapters[kind] {
            return viewAdapter
        } else {
            let viewAdapter = kind.instantiate(play: self)
            viewAdapters[kind] = viewAdapter
            return viewAdapter
        }
    }
}

extension Vector {
    var rounded: Self {
        Self(round(x), round(y), round(z))
    }
}

typealias Axis = RotationAxis3D

extension Axis {
    static prefix func - (axis: Self) -> Self {
        Self(-axis.vector)
    }
}

extension Face {
    var axis: Axis {
        switch self {
        case .right: .x
        case .left: -.x
        case .up: .y
        case .down: -.y
        case .front: .z
        case .back: -.z
        }
    }

    var normal: Vector {
        Vector(axis.vector)
    }
}

extension Move {
    var angle: Float {
        .pi * (twice ? 1.0 : 0.5) * (prime ? 1.0 : -1.0)
    }
}

extension Float {
    static func degree(_ value: Self) -> Self {
        .pi * value / 180.0
    }
}
