//
//  Cube3D.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/14/23.
//

import Foundation
import UIKit
import Combine

protocol Model {
    func rebuild(with: Cube)
    func run(move: Move, duration: Double) -> AnyPublisher<Void, Never>
    func setCameraYaw(ratio: Float)

    var view: UIView { get }
    func hitTest(at: CGPoint, cube: Cube) -> Sticker?
}

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

class Play: ObservableObject {
    @Published var cube: Cube = Cube_TestData.turnedCube
    @Published var moves: [Move] = []

    let model: Model = RealityKitModel()

    var requests: [Move] = []
    var running: AnyCancellable?

    var dragging: Dragging? = nil

    var view: UIView {
        model.view
    }

    init() {
        rebuild()
    }

    func rebuild() {
        model.rebuild(with: cube)
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
            if let move = moves.popLast()?.reversed {
                if running != nil {
                    requests.append(move)
                } else {
                    running = run(move: move, speed: .quick)
                }
            }
        } else {
            _ = requests.popLast()
        }
    }

    private func run(move: Move, speed: TurnSpeed) -> AnyCancellable {
        cube = cube.apply(move: move)

        let duration = speed.duration * (debug ? 10.0 : 1.0)
        return model.run(move: move, duration: duration)
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

extension Vector {
    var rounded: Self {
        Self(round(x), round(y), round(z))
    }
}

struct Axis {
    static let X = Vector(1, 0, 0)
    static let Y = Vector(0, 1, 0)
    static let Z = Vector(0, 0, 1)
}

extension Face {
    var axis: Vector {
        switch self {
        case .right: Axis.X
        case .left: -Axis.X
        case .up: Axis.Y
        case .down: -Axis.Y
        case .front: Axis.Z
        case .back: -Axis.Z
        }
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
