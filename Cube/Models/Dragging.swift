//
//  Drag.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/22/23.
//

import Foundation
import UIKit

protocol Dragging {
    func update(at location: CGPoint)
    func end(at location: CGPoint)
}

enum Direction: String, CaseIterable {
    case up, down, left, right

    var horizontal: Bool {
        self == .left || self == .right
    }

    var vertical: Bool {
        !horizontal
    }
}

protocol DirectionDetectable {
    var direction: Direction? { get }
    func update(location: CGPoint, at: Date)
}

let minimumDistance: Float = 3.0
let minimumSpeed: Float = 500.0
let maximumIdle: TimeInterval = 0.1

class DirectionDetector: DirectionDetectable, CustomDebugStringConvertible {
    var locations: [CGPoint] = []
    var oldestUpdate: Date? = nil
    var lastUpdate: Date? = nil

    enum Tilted { case none, left, right }
    let tilted: Tilted

    init(tilted: Tilted = .none) {
        self.tilted = tilted
    }

    var direction: Direction? {
        let speed = speed
        guard speed > minimumSpeed else {
            return nil
        }

        let translation = translation
        let distance = translation.length
        guard distance > minimumDistance else {
            return nil
        }

        switch tilted {
        case .none:
            if abs(Float(translation.x)) >= abs(Float(translation.y)) {
                return translation.x >= 0.0 ? .right : .left
            } else {
                return translation.y >= 0.0 ? .down : .up
            }
        case .left:
            if translation.x >= 0.0 {
                return translation.y >= 0.0 ? .down : .right
            } else {
                return translation.y >= 0.0 ? .left : .up
            }
        case .right:
            if translation.x >= 0.0 {
                return translation.y >= 0.0 ? .right : .up
            } else {
                return translation.y >= 0.0 ? .down : .left
            }
        }
    }

    var speed: Float {
        guard let oldestUpdate, let lastUpdate else {
            return 0.0
        }

        let duration = lastUpdate.timeIntervalSince(oldestUpdate)
        guard duration > 0.0 else {
            return 0.0
        }

        return translation.length / Float(duration)
    }

    var translation: CGPoint {
        guard !locations.isEmpty else {
            return CGPointZero
        }
        let oldest = locations.first!
        let latest = locations.last!
        return CGPointMake(latest.x - oldest.x, latest.y - oldest.y)
    }

    func update(location: CGPoint, at timestamp: Date) {
        if let lastUpdate, timestamp.timeIntervalSince(lastUpdate) >= maximumIdle {
            locations = []
            oldestUpdate = timestamp
        }

        locations.append(location)
        lastUpdate = timestamp

        if oldestUpdate == nil {
            oldestUpdate = timestamp
        }
    }

    var debugDescription: String {
        let speed = String(format: "%.2f", speed)
        let direction = if let direction { direction.rawValue } else { "-" }
        return "Direction: \(direction) Speed: \(speed) Translation: \(translation)"
    }
}

class TurnDragging: Dragging {
    let play: Play
    let sticker: Sticker

    let detector: DirectionDetectable

    init(at location: CGPoint, play: Play, sticker: Sticker) {
        self.play = play
        self.sticker = sticker

        let tilted: DirectionDetector.Tilted = switch sticker.face {
        case .right: .left
        case .left: .right
        default: .none
        }
        self.detector = DirectionDetector(tilted: tilted)

        detector.update(location: location, at: Date.now)
    }

    func update(at location: CGPoint) {
        detector.update(location: location, at: Date.now)
    }

    func end(at location: CGPoint) {
        detector.update(location: location, at: Date.now)

        guard let direction = detector.direction,
              let moveStr = sticker.identifyMove(for: direction),
              let move = Move.from(string: moveStr)
                else { return }

        play.apply(move: move, speed: .normal)
    }
}

class VoidDragging: Dragging {
    init() {
    }

    func update(at location: CGPoint) {
    }

    func end(at location: CGPoint) {
    }
}

extension ViewAdapter {
    func beginDragging(at location: CGPoint, play: Play) -> Dragging? {
        guard let sticker = hitTest(at: location, cube: play.cube) else {
            return nil
        }

        return TurnDragging(at: location, play: play, sticker: sticker)
    }
}

extension Sticker {
    func identifyMove(for direction: Direction) -> String? {
        let (x, y, z) = piece.position.values

        func centerMove() -> String? {
            return if direction.horizontal {
                switch face {
                case .left, .front, .right: "y"
                case .up: "z'"
                default: nil
                }
            } else {
                switch face {
                case .left: "z"
                case .front, .up: "x"
                case .right: "z'"
                default: nil
                }
            }
        }

        func horizontalMove() -> String? {
            switch face {
            case .front, .right, .left:
                switch y {
                case 1: "U"
                case -1: "D'"
                default: "E'"
                }
            case .up:
                switch z {
                case 1: "F'"
                case -1: "B"
                default: "S'"
                }
            default:
                nil
            }
        }

        func verticalMove() -> String? {
            switch face {
            case .front, .up:
                switch x {
                case 1: "R"
                case -1: "L'"
                default: "M'"
                }
            case .right:
                switch z {
                case 1: "F'"
                case -1: "B"
                default: "S'"
                }
            case .left:
                switch z {
                case 1: "F"
                case -1: "B'"
                default: "S"
                }
            default:
                nil
            }
        }

        func identify() -> String? {
            return if piece.kind == .center {
                centerMove()
            } else if direction.horizontal {
                horizontalMove()
            } else {
                verticalMove()
            }
        }

        return identify()?.move(for: direction)
    }
}

extension String {
    func move(for direction: Direction) -> String {
        let (move, other) = parsedMove()
        return (direction == .left || direction == .up) ? move : other
    }

    func parsedMove() -> (String, String) {
        let move = replacing("'", with: "")
        let opposite = move + "'"

        return count == 1 ? (move, opposite) : (opposite, move)
    }
}

extension CGPoint {
    var length: Float {
        sqrtf(powf(Float(x), 2) + powf(Float(y), 2))
    }
}
