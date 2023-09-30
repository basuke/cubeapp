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
        let neighbors: [Face: [Face]] = [
            .right: [.front, .up, .back, .down],
            .up: [.right, .front, .left, .back],
            .front: [.up, .right, .down, .left],
            .left: [.front, .down, .back, .up],
            .down: [.right, .back, .left, .front],
            .back: [.up, .left, .down, .right],
        ]

        func rotate(face: Face, facing: Face, expected: (Face, Face, Face)) {
            var result = face.rotated(by: .clockwise(facing))
            XCTAssert(result == expected.0, "\(face) .clockwise(\(facing)) should be \(expected.0) but \(result)")

            result = face.rotated(by: .flip(facing))
            XCTAssert(result == expected.1, "\(face) .flip(\(facing)) should be \(expected.1) but \(result)")

            result = face.rotated(by: .counterClockwise(facing))
            XCTAssert(result == expected.2, "\(face) .counterClockwise(\(facing)) should be \(expected.2) but \(result)")
        }

        func generateExpectations(_ neighbors: [Face]) -> [(Face, (Face, Face, Face))] {
            assert(neighbors.count == 4)
            let neighbors = neighbors + neighbors

            return [
                (neighbors[0], (neighbors[1], neighbors[2], neighbors[3])),
                (neighbors[1], (neighbors[2], neighbors[3], neighbors[4])),
                (neighbors[2], (neighbors[3], neighbors[4], neighbors[5])),
                (neighbors[3], (neighbors[4], neighbors[5], neighbors[6])),
            ]
        }

        for (face, neighbors) in neighbors {
            rotate(face: face, facing: face, expected: (face, face, face))

            let otherFace = face.opposite
            rotate(face: otherFace, facing: face, expected: (otherFace, otherFace, otherFace))

            for (target, expected) in generateExpectations(neighbors) {
                rotate(face: target, facing: face, expected: expected)
            }
        }
    }

}
