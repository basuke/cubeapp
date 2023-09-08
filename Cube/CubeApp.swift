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
    static func generateCoordinator() -> Coordinator? {
        #if targetEnvironment(macCatalyst)
        ARKitCoordinator()
        #elseif os(xrOS)
        nil
        #else
        SceneKitCoordinator()
        #endif
    }

    static func generatePlay() -> Play {
        Play(coordinator: generateCoordinator())
    }

    @StateObject private var play = generatePlay()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView(play: play)
                .onChange(of: scenePhase) { _, phase in
                    if phase == .inactive {
                        do {
                            try play.save()
                        } catch {
                            fatalError(error.localizedDescription)
                        }
                    }
                }
                .task {
                    do {
                        try play.load()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
        }
    }
}
