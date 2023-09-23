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
        ]

        for (position, moves) in tests {
            let sticker = Sticker(color: .white, position: position)

            for (direction, move) in moves {
                let result = sticker.identifyMove(for: direction)
                XCTAssert(result == move, "\(position): \(direction) should be \(move), but \(result ?? "nil")")
            }
        }
    }
}
