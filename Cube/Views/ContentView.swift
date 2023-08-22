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

    var body: some View {
        VStack {
            HStack {
                Cube3DView(play: play)
            }
            HStack {
                Spacer()
                Cube2DView(cube: play.cube.as2D())
                Spacer()
            }
            .padding(.vertical, 8)
            MoveController(moves: $play.moves) { move in
                play.apply(move: move)
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [SwiftUI.Color(UIColor.white), SwiftUI.Color(UIColor.lightGray)]), startPoint: .top, endPoint: .bottom)
        )
    }
}

#Preview {
    ContentView(play: Play())
}
