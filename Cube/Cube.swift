//
//  Cube.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/7/23.
//

import Foundation

let onFace: Float = 1.5

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

struct Vector {
    var x: Float
    var y: Float
    var z: Float
}

struct Axis {
    static let X = Vector(x: 1, y: 0, z:0)
    static let Y = Vector(x: 0, y: 1, z:0)
    static let Z = Vector(x: 0, y: 0, z:1)
}

struct Sticker {
    var color: Color
    var position: Vector
}

struct Cube {
    var stickers: [Sticker] = []
    
    init() {
        for (face, color) in zip(Face.allCases, Color.allCases) {
            let positions: [Float] = [-1.0, 0, 1.0]
            for y in positions {
                for x in positions {
                    // somehow create position for each stickers
                    let position = Vector(x: x, y: y, z: 1.5)
                    let sticker = Sticker(color: color, position: position)
                    stickers.append(sticker)
                }
            }
        }
    }
}

// Debug

extension Vector: CustomStringConvertible {
    var description: String {
        return "(\(x), \(y), \(z))"
    }
}

extension Cube {
    func printStickers(_ title: String, _ stickers: [Sticker]) {
        print(title)
        for sticker in stickers {
            print("  \(sticker)")
        }
    }
}
