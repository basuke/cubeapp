//
//  PieceTests.swift
//  CubeTests
//
//  Created by Basuke Suzuki on 9/23/23.
//

import XCTest
@testable import Cube

final class PieceTests: XCTestCase {

    func testPieces() throws {
        let cube = Cube()
        XCTAssert(cube.pieces.count == 3 * 3 * 3 - 1)
    }

    func testCornerPiece() throws {
        let cube = Cube()
        let piece = cube.piece(at: Vector(1, 1, 1))!

        XCTAssert(piece.kind == .corner)
        XCTAssert(piece[.up] == .white)
        XCTAssert(piece.sticker(on: .front)?.color == .green)
        XCTAssert(piece.sticker(on: .right)?.color == .red)
    }

    func testRotatedCornerPiece() throws {
        let cube = Cube()
        let piece = cube.piece(at: Vector(1, 1, 1))!

        let rotated = piece.rotated(by: .clockwise(.front))
        XCTAssert(rotated.kind == .corner)
        XCTAssert(rotated.sticker(on: .front)?.color == .green)
        XCTAssert(rotated.sticker(on: .right)?.color == .white)
        XCTAssert(rotated.sticker(on: .down)?.color == .red)
        XCTAssert(rotated.position == Vector(1, -1, 1))
    }
}
