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
        #if targetEnvironment(macCatalyst) || os(xrOS)
        RealityKitModel()
        #else
        SceneKitModel()
        #endif
    }

    static func generateCoordinator(model: Model) -> Coordinator? {
        #if targetEnvironment(macCatalyst)
        ARKitCoordinator(model: model as! RealityKitModel)
        #elseif os(xrOS)
        nil
        #else
        SceneKitCoordinator(model: model as! SceneKitModel)
        #endif
    }

    static func generatePlay() -> Play {
        let model = generateModel()
        return if let coordinator = generateCoordinator(model: model) {
            Play(coordinator: coordinator)
        } else {
            Play(model: model)
        }
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
