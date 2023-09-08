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
            if let model = play.model as? RealityKitModel {
                if model.runner == nil {
                    model.runner = RealityViewActionRunner(content: content)
                }

                content.add(model.entity)
            }
        } update: { content in
            play.model.setCameraYaw(ratio: -yawRatio)
        }
    }
}

#endif
