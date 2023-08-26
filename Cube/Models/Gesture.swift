//
//  Drag.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/22/23.
//

import Foundation
import SceneKit

protocol Dragging {
    func update(at location: CGPoint)
    func end(at location: CGPoint)
}

enum Direction: String {
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

    let tilted: Bool

    init(tilted: Bool = false) {
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

        if tilted {
            if translation.x >= 0.0 {
                return translation.y >= 0.0 ? .down : .right
            } else {
                return translation.y >= 0.0 ? .left : .up
            }
        } else {
            if abs(Float(translation.x)) >= abs(Float(translation.y)) {
                return translation.x >= 0.0 ? .right : .left
            } else {
                return translation.y >= 0.0 ? .down : .up
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

        self.detector = DirectionDetector(tilted: sticker.face == .right)

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

class VoidDragging: Dragging {
    init() {
    }

    func update(at location: CGPoint) {
    }

    func end(at location: CGPoint) {
    }
}

extension Play {
    func hitTest(at location: CGPoint) -> SCNHitTestResult? {
        let options: [SCNHitTestOption : Any] = [
            .searchMode: SCNHitTestSearchMode.closest.rawValue,
        ]

        return view.hitTest(location, options: options).first
    }

    func hitTestForButtons(at location: CGPoint) -> ButtonNode? {
        let options: [SCNHitTestOption : Any] = [
            .rootNode: controllerNode,
        ]

        for result in view.hitTest(location, options: options) {
            var node = result.node
            while node != controllerNode {
                if let node = node as? ButtonNode {
                    return node
                }
                guard let parent = node.parent else {
                    return nil
                }
                node = parent
            }
        }
        return nil
    }

    private func beginDragging(at location: CGPoint) -> Dragging? {
        guard let result = hitTest(at: location) else {
            return nil
        }

        if let button = hitTestForButtons(at: location) {
            button.action()
            return VoidDragging()
        }

        let normal = Vector(cubeNode.convertVector(result.worldNormal, from: nil)).rounded

        guard let sticker = identifySticker(from: result.node, normal: normal) else {
            return nil
        }

        return TurnDragging(at: location, play: self, sticker: sticker)
    }

    func updateDragging(at location: CGPoint) {
        if let dragging {
            dragging.update(at: location)
            return
        }

        dragging = beginDragging(at: location)
    }

    func endDragging(at location: CGPoint) {
        dragging?.end(at: location)
        dragging = nil
    }

    func identifySticker(from node: SCNNode, normal: Vector) -> Sticker? {
        guard let pieceNode = node.parent, node.kind == .sticker else {
            return nil
        }

        let position = Vector(pieceNode.position).rounded + (normal * 0.5)
        return cube.stickers.first { $0.position == position }
    }
}

extension Sticker {
    func identifyMove(for direction: Direction) -> String? {
        let (x, y, z) = position.values
        let face = face

        // center piece
        if x == 0.0 && y == 0.0 {
            return switch direction {
            case .up: "x"
            case .down: "x'"
            case .left: "y"
            case .right: "y'"
            }
        } else if y == 0.0 && z == 0.0 {
            return switch direction {
            case .up: "z'"
            case .down: "z"
            case .left: "y"
            case .right: "y'"
            }
        } else if z == 0.0 && x == 0.0 {
            return switch direction {
            case .up: "x"
            case .down: "x'"
            case .left: "z'"
            case .right: "z"
            }
        }

        if direction.horizontal {
            if face == .front || face == .right {
                if y == 1.0 {
                    return direction == .left ? "U" : "U'"
                } else if y == -1.0 {
                    return direction == .right ? "D" : "D'"
                } else {
                    return direction == .right ? "E" : "E'"
                }
            } else if face == .up {
                if z == 1.0 {
                    return direction == .right ? "F" : "F'"
                } else if z == -1.0 {
                    return direction == .left ? "B" : "B'"
                } else {
                    return direction == .right ? "S" : "S'"
                }
            }
        } else {
            if face == .front || face == .up {
                if x == 1.0 {
                    return direction == .up ? "R" : "R'"
                } else if x == -1.0 {
                    return direction == .down ? "L" : "L'"
                } else {
                    return direction == .down ? "M" : "M'"
                }
            } else if face == .right {
                if z == 1.0 {
                    return direction == .down ? "F" : "F'"
                } else if z == -1.0 {
                    return direction == .up ? "B" : "B'"
                } else {
                    return direction == .down ? "S" : "S'"
                }
            }
        }
        return nil
    }
}

extension CGPoint {
    var length: Float {
        sqrtf(powf(Float(x), 2) + powf(Float(y), 2))
    }
}