//
//  ContentView.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/6/23.
//

import SwiftUI

struct ContentView: View {
    let cube = Cube2D()

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Cube2DView(cube: cube)
                Spacer()
            }
            Spacer()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(UIColor.white), Color(UIColor.lightGray)]), startPoint: .top, endPoint: .bottom)
        )
    }
}

#Preview {
    ContentView()
}
