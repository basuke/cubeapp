//
//  VectorTests.swift
//  CubeTests
//
//  Created by Basuke Suzuki on 9/28/23.
//

import XCTest
@testable import Cube

final class VectorTests: XCTestCase {

    func testRotation() throws {
        let vec = Vector(1, 1, 1)

        XCTAssert(vec.rotated(by: .clockwise(.front)) == Vector(1, -1, 1))
        XCTAssert(vec.rotated(by: .clockwise(.up)) == Vector(-1, 1, 1))
        XCTAssert(vec.rotated(by: .clockwise(.back)) == Vector(-1, 1, 1))
    }

}
