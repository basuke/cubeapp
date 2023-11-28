//
//  CubeApp.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/6/23.
//

import SwiftUI
import RealityKit

let debug = false

@main
struct CubeApp: App {
    @StateObject private var play = Play()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        StickerComponent.registerComponent()
        RotationSystem.registerSystem()
        
        if debug {
//            DebugHandComponent.registerComponent()
//            DebugHandSystem.registerSystem()
        }
    }

#if os(visionOS)
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    let width: CGFloat = 1
    let height: CGFloat = 1
    let depth: CGFloat = 1

    var body: some SwiftUI.Scene {
        WindowGroup {
            RealityCubeView()
        }
        .environmentObject(play)

        ImmersiveSpace(id: "cube") {
            ImmersiveCubeView()
                .persistent(to: play)
        }
        .environmentObject(play)
    }
#else
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(play)
                .persistent(to: play)
        }
    }
#endif
}
