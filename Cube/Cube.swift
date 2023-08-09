//
//  Cube.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/7/23.
//

import Foundation

let onFace: Float = 1.5

enum Color: Character, CaseIterable {
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

struct Vector {
    var x: Float
    var y: Float
    var z: Float
    
    var negative: Self {
        Self(x: -x, y: -y, z: -z)
    }
    
    var values: (Float, Float, Float) {
        (x, y, z)
    }
}

enum Rotation {
    case clockwise, counterClockwise, flip

    var reversed: Self {
        switch self {
        case .clockwise: return .counterClockwise
        case .counterClockwise: return .clockwise
        case .flip: return self
        }
    }

    var angle: Float {
        switch self {
        case .clockwise: -.pi / 2
        case .counterClockwise: .pi / 2
        case .flip: .pi
        }
    }
}

extension Vector {
    func rotate(on axis: Vector, by angle: Rotation) -> Vector {
        func cleanup(_ value: Float) -> Float {
            return roundf(value * 2) / 2 // because value can be one of (0, 1, -1, 1.5, -1.5)
        }

        func rotate2d(_ x: Float, _ y: Float, _ rotation: Rotation, flipped: Bool) -> (Float, Float) {
            let rotation = flipped ? rotation.reversed : angle
            let sin_t = sin(rotation.angle)
            let cos_t = cos(rotation.angle)
            return (cleanup(x * cos_t - y * sin_t), cleanup(x * sin_t + y * cos_t))
        }

        var (x, y, z) = values
        if axis.x != 0 {
            assert(axis.y == 0 && axis.z == 0, "Invalid axis")
            (y, z) = rotate2d(y, z, angle, flipped: axis.x < 0)
        } else if axis.y != 0 {
            assert(axis.x == 0 && axis.z == 0, "Invalid axis")
            (z, x) = rotate2d(z, x, angle, flipped: axis.y < 0)
        } else if axis.z != 0 {
            assert(axis.x == 0 && axis.y == 0, "Invalid axis")
            (x, y) = rotate2d(x, y, angle, flipped: axis.z < 0)
        } else {
            assert(false, "Invalid axis")
        }
        return Self(x: x, y: y, z: z)
    }
}

struct Axis {
    static let X = Vector(x: 1, y: 0, z:0)
    static let Y = Vector(x: 0, y: 1, z:0)
    static let Z = Vector(x: 0, y: 0, z:1)
}

struct Sticker {
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

struct Cube {
    var stickers: [Sticker] = []
    
    init() {
        func stickerPosition(_ x: Float, _ y: Float, face: Face) -> Vector {
            switch face {
            case .right: Vector(x: onFace, y: y, z: x)
            case .left: Vector(x: -onFace, y: y, z: x)
            case .up: Vector(x: y, y: onFace, z: x)
            case .down: Vector(x: y, y: -onFace, z: x)
            case .front: Vector(x: x, y: y, z: onFace)
            case .back: Vector(x: x, y: y, z: -onFace)
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
        cube
            .apply(moves: [
                Move(.U),
                Move(.x),
                Move(.R),
                Move(.y, prime: true),
                Move(.F, prime: true),
                Move(.D, twice: true),
                Move(.z, twice: true),
                Move(.L),
                Move(.B),
            ])
    }
}
