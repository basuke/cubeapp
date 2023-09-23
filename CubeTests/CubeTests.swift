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
        let sticker = Sticker(color: .white, position: Vector(1.5, 1.0, 1.0))

        let moves: [Direction:String] = [.up: "F'", .down: "F", .left: "U", .right: "U'"]
        for (direction, move) in moves {
            XCTAssert(sticker.identifyMove(for: direction) == move)
        }
    }
}
