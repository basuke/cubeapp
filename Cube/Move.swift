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

    var axis: Vector {
        if [.R].contains(self) {
            return Axis.X
        } else if [.L].contains(self) {
            return Axis.X.negative
        } else if [.U].contains(self) {
            return Axis.Y
        } else if [.D].contains(self) {
            return Axis.Y.negative
        } else if [.F].contains(self) {
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
    
    var reversed: Move {
        return Self(move, prime: !prime, twice: twice)
    }
}

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
}
