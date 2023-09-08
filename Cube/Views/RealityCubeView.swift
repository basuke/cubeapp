//
//  RealityCubeView.swift
//  Cube
//
//  Created by Basuke Suzuki on 9/8/23.
//

import SwiftUI
import SceneKit
import RealityKit
import Combine

#if os(xrOS)

struct RealityCubeView: View {
    @ObservedObject var play: Play
    @Binding var yawRatio: Float

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
        RealityView { content in
            if play.coordinator == nil {
                let runner = RealityViewActionRunner(content: content)
                play.coordinator = RealityViewCoordinator(runner: runner)
            }

            if let coordinator = play.coordinator as? RealityViewCoordinator {
                content.add(coordinator.entity)
            }
        } update: { content in
            play.coordinator?.setCameraYaw(ratio: -yawRatio)
        }
    }
}

#Preview {
    ContentView(play: Play())
}

#endif
