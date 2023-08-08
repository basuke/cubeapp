//
//  Move.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/8/23.
//

import Foundation

// Define moves

enum Move: Character, CaseIterable {
    case U = "U"
    case F = "F"
    case R = "R"

    var axis: Vector {
        if [.R].contains(self) {
            return Axis.X
        } else if [.U].contains(self) {
            return Axis.Y
        } else if [.F].contains(self) {
            return Axis.Z
        } else {
            assert(false)
        }
    }
    
    var filter: (Sticker) -> Bool {
        switch self {
        case .R: return { $0.position.x > 0 }
        case .U: return { $0.position.y > 0 }
        case .F: return { $0.position.z > 0 }
        }
    }
}

extension Cube {
    func apply(move: Move, prime: Bool = false, twice: Bool = false) -> Self {
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
}
