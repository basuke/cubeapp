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
