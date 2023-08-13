//
//  CubeApp.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/6/23.
//

import SwiftUI

@main
struct CubeApp: App {
    @StateObject private var store = DataStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView(cube: $store.cube)
            .onChange(of: scenePhase) { phase in
                if phase == .inactive {
                    do {
                        try store.save()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
            .task {
                do {
                    try store.load()
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
}
