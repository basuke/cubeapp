//
//  ContentView.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/6/23.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    @Binding var cube: Cube
    @Binding var moves: [Move]
    let cube3D = Cube3D(with: Cube())

    var body: some View {
        VStack {
            HStack {
                SceneView(scene: cube3D.scene)
            }
            HStack {
                Spacer()
                Cube2DView(cube: cube.as2D())
                Spacer()
            }
            .padding(.vertical, 8)
            MoveController(moves: $moves) { move in
                cube = cube.apply(move: move)
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [SwiftUI.Color(UIColor.white), SwiftUI.Color(UIColor.lightGray)]), startPoint: .top, endPoint: .bottom)
        )
    }
}

#Preview {
    ContentView(cube: .constant(Cube()), moves: .constant([]))
}
