//
//  Cube.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/7/23.
//

import Foundation

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

// 2D Display

struct Cube2D {
    var colors: [Color]
    
    init() {
        colors = []
        for color in Color.allCases {
            for _ in 1...9 {
                colors.append(color)
            }
        }
    }
    
    private func index(of face: Face, index: Int) -> Int {
        return face.rawValue * 9 + index
    }

    func color(of face: Face, index: Int) -> Color {
        colors[self.index(of: face, index: index)]
    }
}
