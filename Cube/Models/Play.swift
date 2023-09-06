//
//  Cube3D.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/14/23.
//

import Foundation
import UIKit

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

protocol Model {
    func rebuild(with: Cube)
    func run(move: Move, duration: Double, afterAction: @escaping () -> Void)
    func hitTest(at: CGPoint, cube: Cube) -> Sticker?
    func setCameraYaw(ratio: Float)

    var view: UIView { get }
}

class Play: ObservableObject {
    @Published var cube: Cube = Cube()
    @Published var moves: [Move] = []

    let model: Model

    var running: Bool = false
    var requests: [Move] = []

    var dragging: Dragging? = nil

    var view: UIView {
        model.view
    }

    init(model: Model) {
        self.model = model

        rebuild()
    }

    func rebuild() {
        model.rebuild(with: cube)
    }

    func apply(move: Move, speed: TurnSpeed = .normal) {
        guard !running else {
            requests.append(move)
            return
        }

        moves.append(move)
        run(move: move, speed: speed)
    }

    func undo() {
        if requests.isEmpty {
            if let move = moves.popLast() {
                if running {
                    requests.append(move.reversed)
                } else {
                    run(move: move.reversed, speed: .quick)
                }
            }
        } else {
            _ = requests.popLast()
        }
    }

    private func run(move: Move, speed: TurnSpeed) {
        cube = cube.apply(move: move)
        running = true

        let duration = speed.duration * (debug ? 10.0 : 1.0)
        model.run(move: move, duration: duration) {
            self.afterAction()
        }
    }

    private func afterAction() {
        if requests.isEmpty {
            running = false
        } else {
            let move = requests.removeFirst()
            run(move: move, speed: .quick)
        }
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
