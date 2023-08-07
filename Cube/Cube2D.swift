//
//  Cube2D.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/6/23.
//

import Foundation

struct Cube2D {
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
    
    var colors: [Color]
    
    init() {
        colors = []
        for color in Color.allCases {
            for _ in 0..<9 {
                colors.append(color)
            }
        }
    }
    
    func color(of face: Face, index: Int) -> Color {
        colors[face.rawValue * 9 + index]
    }
}
