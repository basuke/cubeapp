//
//  CubeTests.swift
//  CubeTests
//
//  Created by Basuke Suzuki on 9/23/23.
//

import XCTest
@testable import Cube

final class StickerTests: XCTestCase {
    func testIdentifyMove() throws {
        let horizontal: [Face:[String]] = [
            .up: [
                "B", "B", "B",
                "S'","z'","S'",
                "F'","F'","F'"
            ],
            .right: [
                "U", "U", "U",
                "E'","y", "E'",
                "D'","D'","D'"
            ],
            .front: [
                "U", "U", "U",
                "E'","y", "E'",
                "D'","D'","D'"
            ],
            .left: [
                "U", "U", "U",
                "E'","y", "E'",
                "D'","D'","D'"
            ],
        ]

        let vertical: [Face:[String]] = [
            .right: [
                "F'","S'","B",
                "F'","z'","B",
                "F'","S'","B"
            ],
            .up: [
                "L'","M'","R",
                "L'","x", "R",
                "L'","M'","R"
            ],
            .front: [
                "L'","M'","R",
                "L'","x", "R",
                "L'","M'","R"
            ],
            .left: [
                "B'","S", "F",
                "B'","z", "F",
                "B'","S", "F"
            ],
        ]

        var count = 0
        let cube = Cube()

        func test(_ face: Face, _ index: Int, _ direction: Direction, _ tests: [String]?) {
            let piece = cube.piece(on: face, index: index)
            let sticker = piece.sticker(on: face)!

            if let tests {
                let move = tests[index].move(for: direction)
                let result = sticker.identifyMove(for: direction)
                XCTAssert(result == move, "\(face)\(index): \(direction) should be \(move), but \(result ?? "nil")")
                count += 1
            } else {
                let result = sticker.identifyMove(for: direction)
                XCTAssert(result == nil, "\(face)\(index): \(direction) should be nil, but \(result ?? "nil")")
                count += 1
            }
        }

        for face in Face.allCases {
            for index in 0..<9 {
                test(face, index, .left, horizontal[face])
                test(face, index, .right, horizontal[face])
                test(face, index, .up, vertical[face])
                test(face, index, .down, vertical[face])
            }
        }

        XCTAssert(count == 3 * 3 * 6 * 4)
    }

    func testParseMoveStr() throws {
        XCTAssert("R".parsedMove() == ("R", "R'"))
        XCTAssert("F'".parsedMove() == ("F'", "F"))

        XCTAssert("L".move(for: .up) == "L")
        XCTAssert("L".move(for: .down) == "L'")

        XCTAssert("x'".move(for: .left) == "x'")
        XCTAssert("x'".move(for: .right) == "x")
    }
}

extension Piece {
    func has(_ face: Face) -> Bool {
        colors[face] != nil
    }
}

extension Cube {
    func piece(on face: Face, index: Int) -> Piece {
        let sorted = pieces.filter ({ $0.has(face) }).sorted(by: { $0.index(on: face) < $1.index(on: face) })
        return sorted[index]
    }
}
