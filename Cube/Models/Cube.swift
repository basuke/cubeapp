//
//  Cube.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/7/23.
//

import Foundation

let onFace: Float = 1.5

enum Color: Character, CaseIterable, Codable {
    case white = "W"
    case orange = "O"
    case green = "G"
    case red = "R"
    case blue = "B"
    case yellow = "Y"
}

enum Face: Int, CaseIterable {
    case up = 0
    case left = 1
    case front = 2
    case right = 3
    case back = 4
    case down = 5
}

struct Vector: Equatable, Codable {
    var x: Float
    var y: Float
    var z: Float

    init(_ x: Float, _ y: Float, _ z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }

    var negative: Self {
        Self(-x, -y, -z)
    }

    var values: (Float, Float, Float) {
        (x, y, z)
    }
}

enum Rotation {
    case clockwise, counterClockwise, flip

    var reversed: Self {
        switch self {
        case .clockwise: .counterClockwise
        case .counterClockwise: .clockwise
        case .flip: self
        }
    }

    var sin: Float {
        switch self {
        case .clockwise: -1
        case .counterClockwise: 1
        case .flip: 0
        }
    }

    var cos: Float {
        switch self {
        case .clockwise, .counterClockwise: 0
        case .flip: -1
        }
    }
}

extension Vector {
    func rotate(on axis: Vector, by angle: Rotation) -> Vector {
        var (x, y, z) = values

        func cleanup(_ value: Float) -> Float {
            return roundf(value * 2) / 2 // because value can be one of (0, 1, -1, 1.5, -1.5)
        }

        func rotate2d(_ x: Float, _ y: Float, _ rotation: Rotation, flipped: Bool) -> (Float, Float) {
            let rotation = flipped ? rotation.reversed : rotation
            let sin_t = rotation.sin
            let cos_t = rotation.cos
            return (cleanup(x * cos_t - y * sin_t), cleanup(x * sin_t + y * cos_t))
        }

        switch axis {
        case Axis.X, Axis.X.negative:
            (y, z) = rotate2d(y, z, angle, flipped: axis.x < 0)
        case Axis.Y, Axis.Y.negative:
            (z, x) = rotate2d(z, x, angle, flipped: axis.y < 0)
        case Axis.Z, Axis.Z.negative:
            (x, y) = rotate2d(x, y, angle, flipped: axis.z < 0)
        default:
            assert(false, "Invalid axis")
        }
        return Self(x, y, z)
    }
}

struct Axis {
    static let X = Vector(1, 0, 0)
    static let Y = Vector(0, 1, 0)
    static let Z = Vector(0, 0, 1)
}

struct Sticker: Codable {
    var color: Color
    var position: Vector

    var face: Face {
        if position.y == onFace {
            return .up
        } else if position.y == -onFace {
            return .down
        } else if position.x == onFace {
            return .right
        } else if position.x == -onFace {
            return .left
        } else if position.z == onFace {
            return .front
        } else if position.z == -onFace {
            return .back
        } else {
            assert(false, "Invalid geometry")
        }
    }

    func rotate(on axis: Vector, by angle: Rotation) -> Sticker {
        var rotated = self
        rotated.position = position.rotate(on: axis, by: angle)
        return rotated
    }
}

struct Cube: Codable {
    var stickers: [Sticker] = []

    init() {
        func stickerPosition(_ x: Float, _ y: Float, face: Face) -> Vector {
            switch face {
            case .right: Vector(onFace, y, x)
            case .left: Vector(-onFace, y, x)
            case .up: Vector(y, onFace, x)
            case .down: Vector(y, -onFace, x)
            case .front: Vector(x, y, onFace)
            case .back: Vector(x, y, -onFace)
            }
        }

        for (face, color) in zip(Face.allCases, Color.allCases) {
            let positions: [Float] = [-1.0, 0, 1.0]
            for y in positions {
                for x in positions {
                    let position = stickerPosition(x, y, face: face)
                    let sticker = Sticker(color: color, position: position)
                    stickers.append(sticker)
                }
            }
        }
    }
}

// Debug

extension Sticker: CustomStringConvertible {
    var description: String {
        return "\(face):\(color):\(position)"
    }
}

extension Vector: CustomStringConvertible {
    var description: String {
        return "(\(x), \(y), \(z))"
    }
}

extension Cube {
    func printStickers(_ title: String, _ stickers: [Sticker]) {
        print(title)
        for sticker in stickers {
            print("  \(sticker)")
        }
    }
}

// Test data

struct Cube_TestData {
    static var cube: Cube {
        Cube()
    }

    static var turnedCube: Cube {
        cube.apply(moves: "U x R y' F' D2 z2 L B")
    }
}
