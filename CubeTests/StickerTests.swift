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
        let tests: [Face:(horizontal: [String], vertical: [String])] = [
            .right: (horizontal: [
                "U", "U", "U",
                "E'","y", "E'",
                "D'","D'","D'"
            ], vertical: [
                "F'","S'","B",
                "F'","z'","B",
                "F'","S'","B"
            ]),
            .up: (horizontal: [
                "B", "B", "B",
                "S'","z'","S'",
                "F'","F'","F'"
            ], vertical: [
                "L'","M'","R",
                "L'","x", "R",
                "L'","M'","R"
            ]),
            .front: (horizontal: [
                "U", "U", "U",
                "E'","y", "E'",
                "D'","D'","D'"
            ], vertical: [
                "L'","M'","R",
                "L'","x", "R",
                "L'","M'","R"
            ]),
            .left: (horizontal: [
                "U", "U", "U",
                "E'","y", "E'",
                "D'","D'","D'"
            ], vertical: [
                "B'","S", "F",
                "B'","z", "F",
                "B'","S", "F"
            ]),
        ]
        var count = 0

        func test(_ face: Face, _ index: Int) -> Int {
            var count = 0
            let cube = Cube()
            let piece = cube.piece(on: face, index: index)
            let sticker = piece.sticker(on: face)!

            if let (horizontalTest, verticalTest) = tests[face] {
                func parse(_ str: String) -> (String, String) {
                    let move = str.replacing("'", with: "")
                    let opposite = move + "'"

                    return str.count == 1 ? (move, opposite) : (opposite, move)
                }

                let (leftMove, rightMove) = parse(horizontalTest[index])
                let (upMove, downMove) = parse(verticalTest[index])
                let moves: [Direction:String] = [.left: leftMove, .right: rightMove, .up: upMove, .down: downMove]

                for (direction, move) in moves {
                    let result = sticker.identifyMove(for: direction)
                    XCTAssert(result == move, "\(face)\(index): \(direction) should be \(move), but \(result ?? "nil")")
                    count += 1
                }
            } else {
                for direction in Direction.allCases {
                    let result = sticker.identifyMove(for: direction)
                    XCTAssert(result == nil, "\(face)\(index): \(direction) should be nil, but \(result ?? "nil")")
                    count += 1
                }
            }

            return count
        }

        for face in Face.allCases {
            for index in 0..<9 {
                count += test(face, index)
            }
        }

        XCTAssert(count == 3 * 3 * 6 * 4)
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
