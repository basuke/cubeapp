//
//  ContentView.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/6/23.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @ObservedObject var play: Play
    @State private var yawRatio: Float = -1.0

    let gradientColors: [UIColor] = [
        UIColor.lightGray,
        UIColor.white,
        UIColor.lightGray,
    ]

    var flatWindowBody: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Cube3DView(play: play, kind: .sceneKit, yawRatio: $yawRatio)
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

#if os(visionOS)
    var visionWindowBody: some View {
        HStack {
            MoveController.SubButtons()
            VStack {
                Cube2DView(cube: play.cube.as2D()).padding()
                Spacer()
                RealityCubeView(play: play)
            }
            MoveController.MainButtons()
        }
    }
#endif

    var body: some View {
#if os(visionOS)
        visionWindowBody
#else
        flatWindowBody
#endif
    }
}

#Preview {
    ContentView(play: Play())
}
