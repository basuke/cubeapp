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
            Vector(1.5, 1.0, 1.0): [.up: "F'", .down: "F", .left: "U", .right: "U'"],
        ]

        for (position, moves) in tests {
            let sticker = Sticker(color: .white, position: position)

            for (direction, move) in moves {
                XCTAssert(sticker.identifyMove(for: direction) == move)
            }
        }
    }
}
