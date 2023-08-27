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

        if abs(Float(translation.x)) >= abs(Float(translation.y)) {
            return translation.x >= 0.0 ? .right : .left
        } else {
            return translation.y >= 0.0 ? .down : .up
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

    let detector: DirectionDetectable = DirectionDetector()

    init(at location: CGPoint, play: Play, sticker: Sticker) {
        self.play = play
        self.sticker = sticker

        detector.update(location: location, at: Date.now)
    }

    func update(at location: CGPoint) {
        detector.update(location: location, at: Date.now)
    }

    func end(at location: CGPoint) {
        detector.update(location: location, at: Date.now)

        guard let direction = detector.direction else {
            return
        }

        let move = switch direction {
        case .up: "R"
        case .down: "R'"
        case .left: "U"
        case .right: "U'"
        }

        if let move = Move.from(string: move) {
            play.apply(move: move)
        }
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

    private func beginDragging(at location: CGPoint) -> Dragging? {
        guard let result = hitTest(at: location) else {
            return nil
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

        dragging = beginDragging(at: location) ?? VoidDragging()
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

extension CGPoint {
    var length: Float {
        sqrtf(powf(Float(x), 2) + powf(Float(y), 2))
    }
}
