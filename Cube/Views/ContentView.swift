//
//  ContentView.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/6/23.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    @ObservedObject var play: Play

    let gradientColors: [UIColor] = [
        UIColor.lightGray,
        UIColor.white,
        UIColor.lightGray,
    ]

    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Cube2DView(cube: play.cube.as2D())
                Cube3DView(play: play)
            }
            MoveController(canUndo: !play.moves.isEmpty) { move in
                if let move {
                    play.apply(move: move)
                } else {
                    play.undo()
                }
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: gradientColors.map { SwiftUI.Color($0) }), startPoint: .top, endPoint: .bottom)
        )
    }
}

#Preview {
    ContentView(play: Play())
}
