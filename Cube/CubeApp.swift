//
//  CubeApp.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/6/23.
//

import SwiftUI

let debug = false

@main
struct CubeApp: App {
    @StateObject private var play = Play()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        StickerComponent.registerComponent()
        RotationSystem.registerSystem()
    }

    var body: some Scene {
#if os(visionOS)
        WindowGroup {
            RealityCubeView()
                .environmentObject(play)
                .persistent(to: play)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.2, height: 0.2, depth: 0.2, in: .meters)
#else
        WindowGroup {
            ContentView()
                .environmentObject(play)
                .persistent(to: play)
        }
#endif
    }
}
