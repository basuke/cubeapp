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

    var body: some Scene {
        WindowGroup {
            ContentView(cube: $store.cube)
        }
    }
}
