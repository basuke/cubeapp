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
    @State private var yawRatio: Float = 1.0

    let gradientColors: [UIColor] = [
        UIColor.lightGray,
        UIColor.white,
        UIColor.lightGray,
    ]

    class RealityViewActionRunner: ActionRunner {
        var subscription: EventSubscription? = nil
        var action: Action? = nil

        init(content: RealityViewContent) {
            subscription = content.subscribe(to: AnimationEvents.PlaybackCompleted.self) { _ in
                guard let action = self.action else { return }
                action()
            }
        }

        func register(action: @escaping Action) {
            self.action = action
        }
    }

    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                #if os(xrOS)
                RealityView { content in
                    if play.model == nil {
                        let runner = RealityViewActionRunner(content: content)
                        play.model = RealityKitModel(runner: runner)
                    }

                    if let model = play.model as? RealityKitModel {
                        content.add(model.entity)
                    }
                } update: { content in
                    play.model?.setCameraYaw(ratio: yawRatio)
                }
                #else
                Cube3DView(play: play, yawRatio: $yawRatio)
                #endif

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
}

#Preview {
    ContentView(play: Play(model: SceneKitModel()))
}
