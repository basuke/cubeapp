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
    @State private var yawRatio: Float = 1.0
    @StateObject private var motion = DeviceMotion()

    let gradientColors: [UIColor] = [
        UIColor.lightGray,
        UIColor.white,
        UIColor.lightGray,
    ]

    func formattedText(_ value: Double) -> some View {
        let degree = Int(value * 180.0 / .pi)
        let str = String(format: "%d", degree)
        return Text(str)
    }

    func guage(label: String, value: Double, color: UIColor) -> some View {
        let degree = value * 180.0 / .pi
        return Gauge(value: degree, in: -180...180) {
            Text(label)
                .foregroundColor(.init(uiColor: color))
        } currentValueLabel: {
            Text("\(Int(degree))")
                .foregroundColor(.init(uiColor: color))
        }
        .gaugeStyle(.accessoryCircular)
        .tint(.init(uiColor: color))
    }

    var debugPanel: some View {
        return HStack {
            Spacer()
            Slider(
                value: $yawRatio,
                in: -3.0...3.0
            )
            .frame(width: 120)
            VStack {
                guage(label: "Pitch", value: motion.pitch, color: .blue)
                guage(label: "Yaw", value: motion.yaw, color: .green)
                guage(label: "Roll", value: motion.roll, color: .red)
            }
            .frame(width:64, alignment: .trailing)
        }
    }

    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Cube3DView(play: play, yawRatio: $yawRatio)
                HStack {
                    Cube2DView(cube: play.cube.as2D())
                    Spacer()
                }
                .padding()

                debugPanel
                    .padding()
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
