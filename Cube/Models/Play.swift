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
import SwiftUI
import AVKit

enum TurnSpeed: TimeInterval, RawRepresentable {
    case normal = 0.3
    case quick = 0.1
    case superQuick = 0.03

    var duration: TimeInterval {
        self.rawValue * (debug ? 5.0 : 1.0)
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
    func reset()
    func rebuild(with: Cube)
    func startSpinning()
    func stopSpinning()
    func run(move: Move, duration: Double) -> AnyPublisher<Void, Never>
    func setCameraYaw(ratio: Float)
}

protocol ViewAdapter {
    init(model: Model)
    func hitTest(at: CGPoint, cube: Cube) -> Sticker?
    var view: UIView { get }
}

struct HistoryItem: Identifiable {
    private(set) var id = UUID()
    let cube: Cube
    let move: Move
}

class Play: ObservableObject {
    @Published var cube: Cube = Cube()
    @Published var undoItems: [HistoryItem] = []
    @Published var redoItems: [HistoryItem] = []

    @Published var playing: Bool = false
    @Published var scrambling: Bool = false
    @Published var solved: Bool = false
    @Published var celebrated: Bool = false
    @Published var spinning: Bool = false

#if os(visionOS)
    @Published var inWindow: Bool = false
    @Published var inImmersiveSpace: Bool = false
#endif

    @Published var tabSelection = 0
    @Published var transparent: Bool = false

    private var models: [ModelKind:Model] = [:]
    private var viewAdapters: [ViewAdapterKind:ViewAdapter] = [:]

    var requests: [Move] = []
    @Published var running: AnyCancellable?

    var fanfarePlayer = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "fanfare", withExtension: "mp3")!)

    func celebrate() {
        fanfarePlayer.numberOfLoops = 0
        fanfarePlayer.volume = 0.6
        fanfarePlayer.currentTime = 0
        fanfarePlayer.play()

        startSpinning()

        celebrated = true
    }

    func startSpinning() {
        guard !spinning else {
            return
        }

        forEachModel { $0.startSpinning() }
        spinning = true
    }

    func stopSpinning() {
        guard spinning else {
            return
        }

        forEachModel { $0.stopSpinning() }
        spinning = false
    }

    // decide which UI element should be active/disabled.
    var isInteractive: Bool {
        canPlay && running == nil && requests.isEmpty && !transparent
    }

    // decide which UI element should be displayed.
    var canPlay: Bool {
        playing && !scrambling
    }

    func cancel() {
        stopSpinning()
        forEachModel { $0.reset() }
    }

    func rebuild() {
        forEachModel { $0.rebuild(with: cube) }
    }

    func apply(move: Move, speed: TurnSpeed = .normal) {
        guard running == nil else {
            requests.append(move)
            return
        }

        pushUndoAndRun(move: move, speed: speed)
    }

    private func run(move: Move, speed: TurnSpeed) -> AnyCancellable {
        cube = cube.apply(move: move)

        let results = models.values.map { $0.run(move: move, duration: speed.duration) }
        return Publishers.MergeMany(results)
            .receive(on: DispatchQueue.main)
            .sink { self.afterAction() }
    }

    private func afterAction() {
        if requests.isEmpty {
            withAnimation {
                scrambling = false
                running = nil

                if cube.solved {
                    playing = false
                    solved = true

                    celebrate()
                }
            }
        } else {
            pushUndoAndRun(move: requests.removeFirst(), speed: .quick)
        }
    }
}

// Model kind

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

// View adapter kind

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

// Extension to basic components

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

// Undo and redo

extension Play {
    func undo(speed: TurnSpeed = .quick) {
        guard canUndo else {
            return
        }

        if let item = undoItems.popLast() {
            redoItems.append(HistoryItem(cube:cube, move: item.move))
            running = run(move: item.move.reversed, speed: speed)
        }
    }

    var canUndo: Bool {
        !undoItems.isEmpty && isInteractive
    }

    func redo(speed: TurnSpeed = .quick) {
        guard canRedo else {
            return
        }

        if let item = redoItems.popLast() {
            undoItems.append(HistoryItem(cube: cube, move: item.move))
            running = run(move: item.move, speed: speed)
        }
    }

    var canRedo: Bool {
        !redoItems.isEmpty && isInteractive
    }

    private func pushUndoAndRun(move: Move, speed: TurnSpeed) {
        if !scrambling {
            appendUndoMove(cube: cube, move: move)
        }

        running = run(move: move, speed: speed)
    }

    private func appendUndoMove(cube: Cube, move: Move) {
        undoItems.append(HistoryItem(cube: cube, move: move))
        redoItems = []
    }
}
