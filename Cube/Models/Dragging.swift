//
//  Drag.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/22/23.
//

import Foundation
import UIKit
import Spatial

protocol Dragging {
    func update(at location: CGPoint)
    func end(at location: CGPoint)
}

protocol Dragging3D {
    func update(location3D: Point3D)
    func end(location3D: Point3D)
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

protocol DirectionDetectable3D {
    var direction: Vector? { get }
    func update(location3D: Point3D, at: Date)
}

let minimumDistance: Float = 3.0
let minimumSpeed: Float = 500.0
let maximumIdle: TimeInterval = 0.1

class MementStorage<T> {
    var storage: [T] = []
    var oldestUpdate: Date? = nil
    var lastUpdate: Date? = nil

    func update(value: T, at timestamp: Date) {
        if let lastUpdate, timestamp.timeIntervalSince(lastUpdate) >= maximumIdle {
            storage = []
            oldestUpdate = timestamp
        }

        storage.append(value)
        lastUpdate = timestamp

        if oldestUpdate == nil {
            oldestUpdate = timestamp
        }
    }

    var isEmpty: Bool {
        storage.isEmpty
    }

    var first: T? {
        storage.first
    }

    var last: T? {
        storage.last
    }

    var duration: TimeInterval? {
        guard let lastUpdate, let oldestUpdate else {
            return nil
        }

        return lastUpdate.timeIntervalSince(oldestUpdate)
    }

    func reset(at date: Date) {

    }
}

class DirectionDetector: DirectionDetectable, CustomDebugStringConvertible {
    let locations = MementStorage<CGPoint>()

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
        guard let duration = locations.duration, duration > 0.0 else {
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
        locations.update(value: location, at: timestamp)
    }

    var debugDescription: String {
        let speed = String(format: "%.2f", speed)
        let direction = if let direction { direction.rawValue } else { "-" }
        return "Direction: \(direction) Speed: \(speed) Translation: \(translation)"
    }
}

class DirectionDetector3D: DirectionDetectable3D, CustomDebugStringConvertible {
    let locations = MementStorage<Point3D>()
    let minimumDistance: Double = 0.3
    let minimumSpeed: Double = 0.2

    var direction: Vector? {
        guard speed > minimumSpeed else {
            return nil
        }

        let translation = translation
        guard translation.length > minimumDistance else {
            return nil
        }

        let direction = translation.normalized.rounded
        if direction == .zero {
            return nil
        }

        return direction
    }

    var speed: Double {
        guard let duration = locations.duration, duration > 0.0 else {
            return 0.0
        }

        return translation.length / duration
    }

    var translation: Vector {
        guard !locations.isEmpty else {
            return .zero
        }
        let oldest = locations.first!
        let latest = locations.last!
        return Vector(latest) - Vector(oldest)
    }

    func update(location3D: Point3D, at timestamp: Date) {
        locations.update(value: location3D, at: timestamp)
    }

    var debugDescription: String {
        let speed = String(format: "%.2f", speed)
        let direction = if let direction { direction.description } else { "-" }
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

        play.apply(move: move, speed: .quick)
    }
}

class TurnDragging3D: Dragging3D {
    let play: Play
    let sticker: Sticker

    let detector: DirectionDetectable3D

    init(at location3D: Point3D, play: Play, sticker: Sticker) {
        self.play = play
        self.sticker = sticker

        let tilted: DirectionDetector.Tilted = switch sticker.face {
        case .right: .left
        case .left: .right
        default: .none
        }
        self.detector = DirectionDetector3D()

        detector.update(location3D: location3D, at: Date.now)
    }

    func update(location3D: Point3D) {
        detector.update(location3D: location3D, at: Date.now)
    }

    func end(location3D: Point3D) {
        detector.update(location3D: location3D, at: Date.now)

        guard let direction = detector.direction else { return }

        print(direction)
//        play.apply(move: move, speed: .quick)
    }
}

class VoidDragging: Dragging, Dragging3D {
    init() {
    }

    func update(at location: CGPoint) {
    }

    func end(at location: CGPoint) {
    }

    func update(location3D: Point3D) {
    }

    func end(location3D: Point3D) {
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
