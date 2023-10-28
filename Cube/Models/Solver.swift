//
//  Solver.swift
//  Cube
//
//  Created by Basuke Suzuki on 9/27/23.
//

import Foundation

protocol Goal {
    func reached(_: Cube) -> Bool
}

struct Solved: Goal {
    func reached(_ cube: Cube) -> Bool {
        var detectedColors: [Face:Color] = [:]

        for piece in cube.pieces {
            for (face, color) in piece.colors {
                if let expected = detectedColors[face] {
                    if color != expected {
                        return false
                    }
                } else {
                    detectedColors[face] = color
                }
            }
        }
        return true
    }
}
