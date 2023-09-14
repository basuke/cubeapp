//
//  ContentView.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/6/23.
//

import SwiftUI
import SceneKit
import RealityKit
import Combine

struct ContentView: View {
    @ObservedObject var play: Play
    @State private var yawRatio: Float = -1.0

#if os(xrOS)
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @State private var showCube = false

    var body: some View {
        HStack {
            if !showCube {
                VStack {
                    Cube3DView(play: play, kind: .sceneKit, yawRatio: $yawRatio)
                    Slider(
                        value: $yawRatio,
                        in: -3.0...3.0
                    )
                    .frame(width: 120)
                    .padding()
                }
            }

            VStack {
                Spacer()
                Cube2DView(cube: play.cube.as2D())
                Spacer()
                Toggle("Show / Hide", isOn: $showCube)
                    .onChange(of: showCube) { _, isShowing in
                        if isShowing {
                            openWindow(id: kVolumeCubeWorldId)
                        } else {
                            dismissWindow(id: kVolumeCubeWorldId)
                        }
                    }
                    .toggleStyle(.button)
                MoveController(canUndo: !play.moves.isEmpty) { move in
                    if let move {
                        play.apply(move: move)
                    } else {
                        play.undo()
                    }
                }
            }
        }
    }
#else
    let gradientColors: [UIColor] = [
        UIColor.lightGray,
        UIColor.white,
        UIColor.lightGray,
    ]

    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Cube3DView(play: play, kind: .arKit, yawRatio: $yawRatio)

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
#endif
}
