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
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    let position = Point3D([650, -1200.0, -800.0])

    init() {
        StickerComponent.registerComponent()
        RotationSystem.registerSystem()
    }

    var body: some Scene {
#if os(visionOS)
        WindowGroup {
            VStack {
                Button("Start") {
                    Task {
                        await openImmersiveSpace(id: "cube")
                    }
                }
            }
        }

        ImmersiveSpace(id: "cube") {
            RealityCubeView()
                .environmentObject(play)
                .persistent(to: play)
                .position(x: position.x, y: position.y)
                .offset(z: position.z)
        }
#else
        WindowGroup {
            ContentView()
                .environmentObject(play)
                .persistent(to: play)
        }
#endif
    }
}
