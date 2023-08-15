//
//  Move.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/8/23.
//

import Foundation

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

    var axis: Vector {
        switch self {
        case .R, .Rw, .x:
            Axis.X
        case .L, .Lw, .M:
            Axis.X.negative
        case .U, .Uw, .y:
            Axis.Y
        case .D, .Dw, .E:
            Axis.Y.negative
        case .F, .Fw, .z, .S:
            Axis.Z
        case .B, .Bw:
            Axis.Z.negative
        }
    }

    var filter: (Sticker) -> Bool {
        switch self {
        case .R: return { $0.position.x > 0 }
        case .L: return { $0.position.x < 0 }
        case .U: return { $0.position.y > 0 }
        case .D: return { $0.position.y < 0 }
        case .F: return { $0.position.z > 0 }
        case .B: return { $0.position.z < 0 }
        case .Rw: return { $0.position.x >= 0 }
        case .Lw: return { $0.position.x <= 0 }
        case .Uw: return { $0.position.y >= 0 }
        case .Dw: return { $0.position.y <= 0 }
        case .Fw: return { $0.position.z >= 0 }
        case .Bw: return { $0.position.z <= 0 }
        case .x: return { _ in true }
        case .y: return { _ in true }
        case .z: return { _ in true }
        case .M: return { $0.position.x == 0 }
        case .E: return { $0.position.y == 0 }
        case .S: return { $0.position.z == 0 }
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

extension Cube {
    func apply(move: PrimitiveMove, prime: Bool = false, twice: Bool = false) -> Self {
        let predicate = move.filter
        let angle: Rotation = twice ? .flip : prime ? .counterClockwise : .clockwise
        let axis = move.axis

        let target = stickers.filter { predicate($0) }
        let moved = target.map { $0.rotate(on: axis, by: angle)}
        let notMoved = stickers.filter { !predicate($0) }

        var newCube = Self()
        newCube.stickers = moved + notMoved
        return newCube
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
