//
//  Cube.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/7/23.
//

import Foundation
import Spatial

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

typealias Vector = Vector3D

extension Vector {
    init(_ x: Double, _ y: Double, _ z: Double) {
        self.init(x: x, y: y, z: z)
    }

    init(_ x: Int, _ y: Int, _ z: Int) {
        self.init(x: Double(x), y: Double(y), z: Double(z))
    }

    var values: (Double, Double, Double) {
        (x, y, z)
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

    func on(_ face: Face) -> Bool {
        self[face] != nil
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

        let positions = [-1, 0, 1]
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

    func pieces(on face: Face) -> [Piece] {
        pieces.filter { $0.on(face) }
    }

    func colors(on face: Face) -> [Color] {
        pieces.compactMap { $0[face] }
    }

    func stickers(on face: Face) -> [Sticker] {
        pieces(on: face).compactMap { $0.sticker(on: face) }
    }

    var solved: Bool {
        for face in Face.allCases {
            let colors = Set(colors(on: face))
            if colors.count > 1 {
                return false
            }
        }
        return true
    }

    static func defaultColors(at x: Int, _ y: Int, _ z: Int) -> [Face:Color] {
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

// Test data

struct Cube_TestData {
    static var cube: Cube {
        Cube()
    }

    static var easyCube: Cube {
        cube.apply(moves: "R'")
    }

    static var turnedCube: Cube {
        cube.apply(moves: "U x R y' F' D2 z2 L B")
    }
}
