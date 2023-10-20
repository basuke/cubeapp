//
//  ContentView.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/6/23.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @EnvironmentObject private var play: Play
    @State private var yawRatio: Float = -1.0

    let gradientColors: [UIColor] = [
        UIColor.lightGray,
        UIColor.white,
        UIColor.lightGray,
    ]

    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Cube3DView(kind: .sceneKit, yawRatio: $yawRatio)
                HStack {
                    Spacer()
                    Cube2DView(cube: play.cube.as2D())
                    Spacer()
                    Slider(
                        value: $yawRatio,
                        in: -3.0...3.0
                    )
                        .frame(width: 120)
                    Spacer()
                }
            }
            MoveController()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: gradientColors.map { SwiftUI.Color($0) }), startPoint: .top, endPoint: .bottom)
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(Play())
}
