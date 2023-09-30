//
//  FaceTests.swift
//  CubeTests
//
//  Created by Basuke Suzuki on 9/30/23.
//

import XCTest
@testable import Cube

final class FaceTests: XCTestCase {

    func testRotation() throws {
        func rotate(face: Face, facing: Face, expected: (Face, Face, Face)) {
            var result = face.rotated(by: .clockwise(facing))
            XCTAssert(result == expected.0, "\(face) .clockwise(\(facing)) should be \(expected.0) but \(result)")

            result = face.rotated(by: .flip(facing))
            XCTAssert(result == expected.1, "\(face) .flip(\(facing)) should be \(expected.1) but \(result)")

            result = face.rotated(by: .counterClockwise(facing))
            XCTAssert(result == expected.2, "\(face) .counterClockwise(\(facing)) should be \(expected.2) but \(result)")
        }

        rotate(face: .up, facing: .up, expected: (.up, .up, .up))
        rotate(face: .down, facing: .up, expected: (.down, .down, .down))
        rotate(face: .right, facing: .up, expected: (.front, .left, .back))
        rotate(face: .front, facing: .up, expected: (.left, .back, .right))
        rotate(face: .left, facing: .up, expected: (.back, .right, .front))
        rotate(face: .back, facing: .up, expected: (.right, .front, .left))
    }

}
