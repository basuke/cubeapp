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

        XCTAssert(sticker.identifyMove(for: .up) == "F'")
        XCTAssert(sticker.identifyMove(for: .down) == "F")

        XCTAssert(sticker.identifyMove(for: .left) == "U")
        XCTAssert(sticker.identifyMove(for: .right) == "U'")
    }
}
