//
//  ContentView.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/6/23.
//

import SwiftUI

struct ContentView: View {
    @Binding var cube: Cube

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Cube2DView(cube: cube.as2D())
                Spacer()
            }
            MoveController() { move in
                cube = cube.apply(move: move)
            }
                .padding()
            Spacer()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [SwiftUI.Color(UIColor.white), SwiftUI.Color(UIColor.lightGray)]), startPoint: .top, endPoint: .bottom)
        )
    }
}

#Preview {
    ContentView(cube: .constant(Cube()))
}
