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
        WindowGroup {
            ContentView(play: play)
                .environmentObject(play)
                .persistent(to: play)
        }
    }
}
