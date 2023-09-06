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
    static func generateModel() -> Model {
        #if os(iOS)
        SceneKitModel()
        #else
        ARKitModel()
        #endif
    }

    static func generatePlay() -> Play {
        Play(model: generateModel())
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
