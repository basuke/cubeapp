//
//  Cube2DView.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/7/23.
//

import SwiftUI

let cellLength: CGFloat = 8
let cellGap: CGFloat = 1
let faceGap: CGFloat = 2

struct Cube2DView: View {
    let cube: Cube2D

    struct Cell: View {
        let color: Color
        
        var body: some View {
            Rectangle()
                .fill(SwiftUI.Color(uiColor: color.uiColor))
                .frame(width: cellLength, height: cellLength)
        }
    }

    struct FaceCell: View {
        let cube: Cube2D
        let face: Face

        var body: some View {
            Grid(horizontalSpacing: cellGap, verticalSpacing: cellGap) {
                GridRow {
                    Cell(color: color(0))
                    Cell(color: color(1))
                    Cell(color: color(2))
                }
                GridRow {
                    Cell(color: color(3))
                    Cell(color: color(4))
                    Cell(color: color(5))
                }
                GridRow {
                    Cell(color: color(6))
                    Cell(color: color(7))
                    Cell(color: color(8))
                }
            }
        }
        
        func color(_ index: Int) -> Color {
            cube.color(of: face, index: index)
        }
    }

    var body: some View {
        VStack {
            Grid(horizontalSpacing: faceGap, verticalSpacing: faceGap) {
                GridRow {
                    Text("")
                    FaceCell(cube: cube, face: .up)
                }
                GridRow {
                    FaceCell(cube: cube, face: .left)
                    FaceCell(cube: cube, face: .front)
                    FaceCell(cube: cube, face: .right)
                    FaceCell(cube: cube, face: .back)
                }
                GridRow {
                    Text("")
                    FaceCell(cube: cube, face: .down)
                }
            }
        }
    }
}

#Preview {
    Cube2DView(cube: Cube_TestData.turnedCube.as2D())
        .padding()
        .background(.gray)
}

// 2D Display

struct Cube2D {
    var colors: [Color]
    
    init() {
        colors = []
        for color in Color.allCases {
            for _ in 1...9 {
                colors.append(color)
            }
        }
    }
    
    private func index(of face: Face, index: Int) -> Int {
        return face.rawValue * 9 + index
    }

    func color(of face: Face, index: Int) -> Color {
        colors[self.index(of: face, index: index)]
    }

    mutating func setColor(of face: Face, index: Int, color: Color) {
        colors[self.index(of: face, index: index)] = color
    }
}

extension Cube {
    func as2D() -> Cube2D {
        var cube = Cube2D()

        for sticker in stickers {
            let face = sticker.face
            cube.setColor(of: face, index: sticker.index, color: sticker.color)
        }

        return cube
    }
}

extension Sticker {
    var index: Int {
        let (x, y, z) = position.values
        
        func indexOf(_ x: Float, _ y: Float) -> Int {
            return (Int(y) + 1) * 3 + (Int(x) + 1)
        }
        
        switch face {
        case .up: return indexOf(x, z)
        case .down: return indexOf(x, -z)
        case .front: return indexOf(x, -y)
        case .back: return indexOf(-x, -y)
        case .right: return indexOf(-z, -y)
        case .left: return indexOf(z, -y)
        }
    }
}

extension Color {
    var uiColor: UIColor {
        switch self {
        case .blue: .blue
        case .green: .green
        case .orange: .orange
        case .red: .red
        case .white: .white
        case .yellow: .yellow
        }
    }
}
