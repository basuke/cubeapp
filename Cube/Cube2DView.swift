//
//  Cube2DView.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/7/23.
//

import SwiftUI

struct Cube2DView: View {
    let cube: Cube2D

    struct Cell: View {
        let color: Color
        
        var body: some View {
            Rectangle()
                .fill(SwiftUI.Color(uiColor: color.uiColor))
                .frame(width: 30, height: 30)
        }
    }

    struct FaceCell: View {
        let cube: Cube2D
        let face: Face

        var body: some View {
            Grid(horizontalSpacing: 1, verticalSpacing: 1) {
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
            Grid(horizontalSpacing: 3, verticalSpacing: 3) {
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
    Cube2DView(cube: Cube2D())
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
