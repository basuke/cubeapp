//
//  CubeTests.swift
//  CubeTests
//
//  Created by Basuke Suzuki on 9/23/23.
//

import XCTest
@testable import Cube

final class CubeTests: XCTestCase {
    func testIdentifyMove() throws {
        typealias MoveMap = [Direction:String]
        let tests: [Vector:MoveMap] = [
            // .right
            Vector(1.5, 1.0, 1.0): [.up: "F'", .down: "F", .left: "U", .right: "U'"],
            Vector(1.5, 1.0, 0.0): [.up: "S'", .down: "S", .left: "U", .right: "U'"],
            Vector(1.5, 1.0, -1.0): [.up: "B", .down: "B'", .left: "U", .right: "U'"],

            Vector(1.5, 0.0, 1.0): [.up: "F'", .down: "F", .left: "E'", .right: "E"],
            Vector(1.5, 0.0, 0.0): [.up: "z'", .down: "z", .left: "y", .right: "y'"],
            Vector(1.5, 0.0, -1.0): [.up: "B", .down: "B'", .left: "E'", .right: "E"],

            Vector(1.5, -1.0, 1.0): [.up: "F'", .down: "F", .left: "D'", .right: "D"],
            Vector(1.5, -1.0, 0.0): [.up: "S'", .down: "S", .left: "D'", .right: "D"],
            Vector(1.5, -1.0, -1.0): [.up: "B", .down: "B'", .left: "D'", .right: "D"],

            // .up
            Vector(-1.0, 1.5, 1.0): [.up: "L'", .down: "L", .left: "F'", .right: "F"],
            Vector(0.0, 1.5, 1.0): [.up: "M'", .down: "M", .left: "F'", .right: "F"],
            Vector(1.0, 1.5, 1.0): [.up: "R", .down: "R'", .left: "F'", .right: "F"],

            Vector(-1.0, 1.5, 0.0): [.up: "L'", .down: "L", .left: "S'", .right: "S"],
            Vector(0.0, 1.5, 0.0): [.up: "x", .down: "x'", .left: "z'", .right: "z"],
            Vector(1.0, 1.5, 0.0): [.up: "R", .down: "R'", .left: "S'", .right: "S"],

            Vector(-1.0, 1.5, -1.0): [.up: "L'", .down: "L", .left: "B", .right: "B'"],
            Vector(0.0, 1.5, -1.0): [.up: "M'", .down: "M", .left: "B", .right: "B'"],
            Vector(1.0, 1.5, -1.0): [.up: "R", .down: "R'", .left: "B", .right: "B'"],

            // .front
            Vector(-1.0, 1.0, 1.5): [.up: "L'", .down: "L", .left: "U", .right: "U'"],
            Vector(0.0, 1.0, 1.5): [.up: "M'", .down: "M", .left: "U", .right: "U'"],
            Vector(1.0, 1.0, 1.5): [.up: "R", .down: "R'", .left: "U", .right: "U'"],

            Vector(-1.0, 0.0, 1.5): [.up: "L'", .down: "L", .left: "E'", .right: "E"],
            Vector(0.0, 0.0, 1.5): [.up: "x", .down: "x'", .left: "y", .right: "y'"],
            Vector(1.0, 0.0, 1.5): [.up: "R", .down: "R'", .left: "E'", .right: "E"],

            Vector(-1.0, -1.0, 1.5): [.up: "L'", .down: "L", .left: "D'", .right: "D"],
            Vector(0.0, -1.0, 1.5): [.up: "M'", .down: "M", .left: "D'", .right: "D"],
            Vector(1.0, -1.0, 1.5): [.up: "R", .down: "R'", .left: "D'", .right: "D"],

            // .left
            Vector(-1.5, 1.0, -1.0): [.up: "B'", .down: "B", .left: "U", .right: "U'"],
            Vector(-1.5, 1.0, 0.0): [.up: "S", .down: "S'", .left: "U", .right: "U'"],
            Vector(-1.5, 1.0, 1.0): [.up: "F", .down: "F'", .left: "U", .right: "U'"],

            Vector(-1.5, 0.0, -1.0): [.up: "B'", .down: "B", .left: "E'", .right: "E"],
            Vector(-1.5, 0.0, 0.0): [.up: "z", .down: "z'", .left: "y", .right: "y'"],
            Vector(-1.5, 0.0, 1.0): [.up: "F", .down: "F'", .left: "E'", .right: "E"],

            Vector(-1.5, -1.0, -1.0): [.up: "B'", .down: "B", .left: "D'", .right: "D"],
            Vector(-1.5, -1.0, 0.0): [.up: "S", .down: "S'", .left: "D'", .right: "D"],
            Vector(-1.5, -1.0, 1.0): [.up: "F", .down: "F'", .left: "D'", .right: "D"],
        ]

        func test(_ x: Float, _ y: Float, _ z: Float) {
            let position = Vector(x, y, z)
            let sticker = Sticker(color: .white, position: position)

            if let moves = tests[position] {
                for (direction, move) in moves {
                    let result = sticker.identifyMove(for: direction)
                    XCTAssert(result == move, "\(position): \(direction) should be \(move), but \(result ?? "nil")")
                }
            } else {
                for direction in Direction.allCases {
                    let result = sticker.identifyMove(for: direction)
                    XCTAssert(result == nil, "\(position): \(direction) should be nil, but \(result ?? "nil")")
                }
            }
        }

        let positions: [Float] = [-1, 0, 1]

        for z in positions {
            for y in positions {
                for x in positions {
                    if (x, y, z) != (0, 0, 0) {
                        if x != 0 {
                            test(x * 1.5, y, z)
                        }
                        if y != 0 {
                            test(x, y * 1.5, z)
                        }
                        if z != 0 {
                            test(x, y, z * 1.5)
                        }
                    }
                }
            }
        }
    }
}
