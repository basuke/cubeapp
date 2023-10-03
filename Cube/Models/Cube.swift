//
//  Cube.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/7/23.
//

import Foundation

enum Color: Character, CaseIterable, Codable {
    case white = "W"
    case orange = "O"
    case green = "G"
    case red = "R"
    case blue = "B"
    case yellow = "Y"
}

enum Face: Int, CaseIterable, Codable {
    case up = 0
    case left = 1
    case front = 2
    case right = 3
    case back = 4
    case down = 5

    var opposite: Self {
        switch self {
        case .right: .left
        case .left: .right
        case .up: .down
        case .down: .up
        case .front: .back
        case .back: .front
        }
    }
}

struct Vector: Equatable, Codable {
    let x: Float
    let y: Float
    let z: Float

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
        Vector(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }

    static func -(lhs: Self, rhs: Self) -> Self {
        lhs + -rhs
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

struct Piece: Codable {
    enum Kind {
        case center, edge, corner
    }

    let position: Vector
    let colors: [Face:Color]

    init(at position: Vector, colors: [Face:Color]) {
        self.position = position
        self.colors = colors

        assert(colors.count >= 1 && colors.count <= 3)
    }

    var kind: Kind {
        switch colors.count {
        case 1: .center
        case 2: .edge
        default: .corner
        }
    }

    subscript(face: Face) -> Color? {
        colors[face]
    }

    func sticker(on face: Face) -> Sticker? {
        guard let _ = self[face] else {
            return nil
        }

        return Sticker(piece: self, face: face)
    }
}

struct Sticker {
    let piece: Piece
    let face: Face

    var color: Color {
        piece[face]!
    }
}

struct Cube: Codable {
    let pieces: [Piece]

    init(pieces: [Piece]) {
        self.pieces = pieces
        precondition(self.pieces.count == 26)
    }

    init() {
        var pieces: [Piece] = []

        let positions: [Float] = [-1, 0, 1]
        for z in positions {
            for y in positions {
                for x in positions {
                    if (x, y, z) != (0, 0, 0) {
                        pieces.append(Piece(at: Vector(x, y, z), colors: Self.defaultColors(at: x, y, z)))
                    }
                }
            }
        }

        self.init(pieces: pieces)
    }

    func piece(at position: Vector) -> Piece? {
        pieces.first { $0.position == position }
    }

    static func defaultColors(at x: Float, _ y: Float, _ z: Float) -> [Face:Color] {
        var colors: [Face:Color] = [:]

        if x == 1 {
            colors[.right] = .red
        } else if x == -1 {
            colors[.left] = .orange
        }

        if y == 1 {
            colors[.up] = .white
        } else if y == -1 {
            colors[.down] = .yellow
        }

        if z == 1 {
            colors[.front] = .green
        } else if z == -1 {
            colors[.back] = .blue
        }

        return colors
    }
}

// Debug

extension Vector: CustomStringConvertible {
    var description: String {
        return "(\(x), \(y), \(z))"
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
