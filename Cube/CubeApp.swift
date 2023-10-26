//
//  CubeApp.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/6/23.
//

import SwiftUI
import RealityKit

let debug = true

@main
struct CubeApp: App {
    @StateObject private var play = Play()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        StickerComponent.registerComponent()
        RotationSystem.registerSystem()
    }

#if os(visionOS)
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    let position = Point3D([600, -1200.0, -800.0])
    let width: CGFloat = 0.5
    let height: CGFloat = 1.5
    let depth: CGFloat = 1.5

    var body: some SwiftUI.Scene {
        WindowGroup {
            ZStack(alignment: .bottom) {
                GeometryReader3D { geometry in
                    if debug {
                        RealityView { content in
                            let t: CGFloat = 0.001

                            let mesh = MeshResource.generateBox(width: Float(width - t), height: Float(height - t), depth: Float(depth - t))
                            let material = SimpleMaterial(color: .red, isMetallic: true)
                            let entity = ModelEntity(mesh: mesh, materials: [material])
                            entity.components.set(OpacityComponent(opacity: 0.1))
                            content.add(entity)
                        }
                    }
                    RealityCubeView(scale: 0.06, translation: Vector(x: 0.0, y: -0.5, z: 0.4))
                }
                Button("Start") {
                    Task {
                        await openImmersiveSpace(id: "cube")
                    }
                }
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: width, height: height, depth: depth, in: .meters)
        .environmentObject(play)

        ImmersiveSpace(id: "cube") {
            RealityCubeView(scale: 0.02, translation: .zero)
                .persistent(to: play)
                .position(x: position.x, y: position.y)
                .offset(z: position.z)
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
