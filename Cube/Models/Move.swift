//
//  Move.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/8/23.
//

import Foundation
import Spatial

// Define moves

enum PrimitiveMove: Character, CaseIterable, Codable {
    case U = "U"
    case D = "D"
    case F = "F"
    case B = "B"
    case R = "R"
    case L = "L"
    case Uw = "u"
    case Dw = "d"
    case Fw = "f"
    case Bw = "b"
    case Rw = "r"
    case Lw = "l"
    case x = "x"
    case y = "y"
    case z = "z"
    case M = "M"
    case E = "E"
    case S = "S"

    var face: Face {
        switch self {
        case .R, .Rw, .x:
                .right
        case .L, .Lw, .M:
                .left
        case .U, .Uw, .y:
                .up
        case .D, .Dw, .E:
                .down
        case .F, .Fw, .z, .S:
                .front
        case .B, .Bw:
                .back
        }
    }

    var filter: (Vector) -> Bool {
        switch self {
        case .R: return { $0.x > 0 }
        case .L: return { $0.x < 0 }
        case .U: return { $0.y > 0 }
        case .D: return { $0.y < 0 }
        case .F: return { $0.z > 0 }
        case .B: return { $0.z < 0 }
        case .Rw: return { $0.x >= 0 }
        case .Lw: return { $0.x <= 0 }
        case .Uw: return { $0.y >= 0 }
        case .Dw: return { $0.y <= 0 }
        case .Fw: return { $0.z >= 0 }
        case .Bw: return { $0.z <= 0 }
        case .x: return { _ in true }
        case .y: return { _ in true }
        case .z: return { _ in true }
        case .M: return { $0.x == 0 }
        case .E: return { $0.y == 0 }
        case .S: return { $0.z == 0 }
        }
    }
}

struct Move: Codable {
    let move: PrimitiveMove
    let prime: Bool
    let twice: Bool

    init(_ move: PrimitiveMove, prime: Bool = false, twice: Bool = false) {
        self.move = move
        self.prime = prime
        self.twice = twice
    }

    enum ParseError: Error {
        case invalidMoveString(String)
    }

    var reversed: Move {
        return Self(move, prime: !prime, twice: twice)
    }

    var filter: (Vector) -> Bool {
        move.filter
    }

    var face: Face {
        move.face
    }

    static func parse(_ movesStr: String) throws -> [Move] {
        try movesStr.components(separatedBy: " ").map { str in
            guard let move = self.from(string: str) else {
                throw ParseError.invalidMoveString(str)
            }
            return move
        }
    }

    static func from(string str: String) -> Move? {
        return allMoves[str]
    }
}

let allMoves: [String:Move] = [
    // face turn

    "U": Move(.U),
    "D": Move(.D),
    "F": Move(.F),
    "B": Move(.B),
    "R": Move(.R),
    "L": Move(.L),

    "U'": Move(.U, prime: true),
    "D'": Move(.D, prime: true),
    "F'": Move(.F, prime: true),
    "B'": Move(.B, prime: true),
    "R'": Move(.R, prime: true),
    "L'": Move(.L, prime: true),

    "U2": Move(.U, twice: true),
    "D2": Move(.D, twice: true),
    "F2": Move(.F, twice: true),
    "B2": Move(.B, twice: true),
    "R2": Move(.R, twice: true),
    "L2": Move(.L, twice: true),

    // wide moves

    "Uw": Move(.Uw),
    "Dw": Move(.Dw),
    "Fw": Move(.Fw),
    "Bw": Move(.Bw),
    "Rw": Move(.Rw),
    "Lw": Move(.Lw),

    "Uw'": Move(.Uw, prime: true),
    "Dw'": Move(.Dw, prime: true),
    "Fw'": Move(.Fw, prime: true),
    "Bw'": Move(.Bw, prime: true),
    "Rw'": Move(.Rw, prime: true),
    "Lw'": Move(.Lw, prime: true),

    "Uw2": Move(.Uw, twice: true),
    "Dw2": Move(.Dw, twice: true),
    "Fw2": Move(.Fw, twice: true),
    "Bw2": Move(.Bw, twice: true),
    "Rw2": Move(.Rw, twice: true),
    "Lw2": Move(.Lw, twice: true),

    // wide moves (alias, lowercase)

    "u": Move(.Uw),
    "d": Move(.Dw),
    "f": Move(.Fw),
    "b": Move(.Bw),
    "r": Move(.Rw),
    "l": Move(.Lw),

    "u'": Move(.Uw, prime: true),
    "d'": Move(.Dw, prime: true),
    "f'": Move(.Fw, prime: true),
    "b'": Move(.Bw, prime: true),
    "r'": Move(.Rw, prime: true),
    "l'": Move(.Lw, prime: true),

    "u2": Move(.Uw, twice: true),
    "d2": Move(.Dw, twice: true),
    "f2": Move(.Fw, twice: true),
    "b2": Move(.Bw, twice: true),
    "r2": Move(.Rw, twice: true),
    "l2": Move(.Lw, twice: true),

    // cube rotation

    "x": Move(.x),
    "y": Move(.y),
    "z": Move(.z),

    "x'": Move(.x, prime: true),
    "y'": Move(.y, prime: true),
    "z'": Move(.z, prime: true),

    "x2": Move(.x, twice: true),
    "y2": Move(.y, twice: true),
    "z2": Move(.z, twice: true),

    // middle layer

    "M": Move(.M),
    "E": Move(.E),
    "S": Move(.S),

    "M'": Move(.M, prime: true),
    "E'": Move(.E, prime: true),
    "S'": Move(.S, prime: true),

    "M2": Move(.M, twice: true),
    "E2": Move(.E, twice: true),
    "S2": Move(.S, twice: true),
]

struct Rotation {
    enum Angle {
        case clockwise, counterClockwise, flip

        var reversed: Self {
            switch self {
            case .clockwise: .counterClockwise
            case .counterClockwise: .clockwise
            case .flip: self
            }
        }

        var sin: Double {
            switch self {
            case .clockwise: -1
            case .counterClockwise: 1
            case .flip: 0
            }
        }

        var cos: Double {
            switch self {
            case .clockwise, .counterClockwise: 0
            case .flip: -1
            }
        }

        func rotate2d(_ x: Double, _ y: Double) -> (Double, Double) {
            return (round(x * cos - y * sin), round(x * sin + y * cos))
        }

        func rotate(vector: Vector, facing face: Face) -> Vector {
            var (x, y, z) = vector.values

            switch face {
            case .right:
                (y, z) = rotate2d(y, z)
            case .left:
                (y, z) = reversed.rotate2d(y, z)
            case .up:
                (z, x) = rotate2d(z, x)
            case .down:
                (z, x) = reversed.rotate2d(z, x)
            case .front:
                (x, y) = rotate2d(x, y)
            case .back:
                (x, y) = reversed.rotate2d(x, y)
            }
            return Vector(x, y, z)
        }
    }

    let face: Face
    let angle: Angle

    func rotate(vector: Vector) -> Vector {
        angle.rotate(vector: vector, facing: face)
    }

    static func clockwise(_ face: Face) -> Self {
        Self(face: face, angle: .clockwise)
    }

    static func counterClockwise(_ face: Face) -> Self {
        Self(face: face, angle: .counterClockwise)
    }

    static func flip(_ face: Face) -> Self {
        Self(face: face, angle: .flip)
    }
}

extension Vector {
    func rotated(by rotation: Rotation) -> Self {
        rotation.rotate(vector: self)
    }
}

extension Axis {
    func rotated(by rotation: Rotation) -> Self {
        Self(Vector(vector).rotated(by: rotation).vector)
    }
}

extension Cube {
    func apply(move: PrimitiveMove, prime: Bool = false, twice: Bool = false) -> Self {
        let predicate = move.filter
        let rotation = Rotation(face: move.face, angle: twice ? .flip : prime ? .counterClockwise : .clockwise)

        let targetPieces = pieces.filter { predicate($0.position) }
        let movedPieces = targetPieces.map { $0.rotated(by: rotation) }
        let notMovedPieces = pieces.filter { !predicate($0.position) }

        return Self(pieces: movedPieces + notMovedPieces)
    }

    func apply(move: Move) -> Self {
        apply(move: move.move, prime: move.prime, twice: move.twice)
    }

    func apply(moves: [Move]) -> Self {
        moves.reduce(self) { $0.apply(move: $1) }
    }

    func apply(moves moveStr: String) -> Self {
        do {
            let moves = try Move.parse(moveStr)
            return apply(moves: moves)
        } catch Move.ParseError.invalidMoveString(let str) {
            print("format error: \(str)")
            return self
        } catch {
            print("unknown error")
            return self
        }
    }
}

extension Face {
    func rotated(by rotation: Rotation) -> Self {
        guard let rotated = Face.init(normal: normal.rotated(by: rotation)) else {
            fatalError("Invalid axis vector")
        }
        return rotated
    }

    init?(normal: Vector) {
        let (x, y, z) = normal.values
        if x == 1.0 {
            assert(y == 0 && z == 0)
            self = .right
        } else if x == -1.0 {
            assert(y == 0 && z == 0)
            self = .left
        } else if y == 1.0 {
            assert(z == 0 && x == 0)
            self = .up
        } else if y == -1.0 {
            assert(z == 0 && x == 0)
            self = .down
        } else if z == 1.0 {
            assert(x == 0 && y == 0)
            self = .front
        } else if z == -1.0 {
            assert(x == 0 && y == 0)
            self = .back
        } else {
            return nil
        }
    }
}

extension Piece {
    func rotated(by rotation: Rotation) -> Self {
        var rotatedColors: [Face:Color] = [:]
        for (face, color) in colors {
            rotatedColors[face.rotated(by: rotation)] = color
        }
        return Self(at: position.rotated(by: rotation), colors: rotatedColors)
    }
}
