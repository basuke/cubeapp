//
//  OrnamentView.swift
//  Cube
//
//  Created by Basuke Suzuki on 11/29/23.
//

import SwiftUI

#if os(visionOS)

extension RealityCubeView {
    struct OrnamentView: View {
        @EnvironmentObject private var play: Play

        var body: some View {
            HStack {
                Button {
                    play.undo(speed: .normal)
                } label: {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                        .labelStyle(.titleAndIcon)
                }
                .disabled(!play.canUndo)
                .padding()

                Button {
                    play.redo(speed: .normal)
                } label: {
                    Label("Redo", systemImage: "arrow.uturn.forward")
                        .labelStyle(.titleAndIcon)
                }
                .disabled(!play.canRedo)
                .padding()

                Cube2DView(cube: play.cube.as2D())

                Button("Scramble") {
                    print("Scramble")
                }
                .padding()
            }
        }
    }
}

#endif

