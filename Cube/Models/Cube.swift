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

    var values: (Float, Float, Float) {
        (x, y, z)
    }

    static prefix func -(vec: Self) -> Self {
        Self(-vec.x, -vec.y, -vec.z)
    }

    static func +(lhs: Self, rhs: Self) -> Self {
        return Vector(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }

    static func *(vec: Self, scale: Double) -> Self {
        let scale = Float(scale)
        return Vector(vec.x * scale, vec.y * scale, vec.z * scale)
    }
}

extension Vector: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }
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
