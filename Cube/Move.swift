//
//  Move.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/8/23.
//

import Foundation

// Define moves

enum PrimitiveMove: Character, CaseIterable {
    case U = "U"
    case D = "D"
    case F = "F"
    case B = "B"
    case R = "R"
    case L = "L"
    case x = "x"
    case y = "y"
    case z = "z"

    var axis: Vector {
        if [.R, .x].contains(self) {
            return Axis.X
        } else if [.L].contains(self) {
            return Axis.X.negative
        } else if [.U, .y].contains(self) {
            return Axis.Y
        } else if [.D].contains(self) {
            return Axis.Y.negative
        } else if [.F, .z].contains(self) {
            return Axis.Z
        } else if [.B].contains(self) {
            return Axis.Z.negative
        } else {
            assert(false)
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
        case .x: return { _ in true }
        case .y: return { _ in true }
        case .z: return { _ in true }
        }
    }
}

struct Move {
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
        return movesStr.components(separatedBy: " ").reduce([]) { $0 + [allMoves[$1]!] }
    }

    static func from(string str: String) -> Move? {
        return allMoves[str]
    }
}

let allMoves: Dictionary<String, Move> = [
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
