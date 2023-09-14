//
//  CubeApp.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/6/23.
//

import SwiftUI

let debug = false
let kVolumeCubeWorldId = "world"

@main
struct CubeApp: App {
    @StateObject private var play = Play()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            #if os(visionOS)
            VolumetircView(play: play)
                .environmentObject(play)
            #else
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
            #endif
        }
#if os(visionOS)
        .windowStyle(.volumetric)
        .defaultSize(width: 0.2, height: 0.2, depth: 0.2, in: .meters)
#endif

        #if os(xrOS)
        WindowGroup(id: kVolumeCubeWorldId) {
            VolumetircView(play: play)
                .environmentObject(play)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.6, height: 0.6, depth: 0.6, in: .meters)
        #endif
    }
}
