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
        @State private var scrambleConfirmation = false

        var body: some View {
            HStack {
                Label("Cube Real", systemImage: "info")
                    .labelStyle(.titleOnly)
                    .padding(.horizontal)
                    .font(.title)

                Button {
                    if play.playing {
                        withAnimation {
                            play.transparent = true
                        }
                        scrambleConfirmation = true
                    } else {
                        play.scramble()
                    }
                } label: {
                    Label("Scramble", systemImage: "shuffle")
                        .labelStyle(.titleAndIcon)
                }
                .alert("Are you sure to scramble the cube?", isPresented: $scrambleConfirmation) {
                    Button("Cancel", role: .cancel) {
                    }

                    Button("Do Scramble", role: .destructive) {
                        Task {
                            play.scramble()
                        }
                    }
                } message: {
                    Text("Current playing cube will be destroyed.")
                        .padding()
                        .font(.subheadline)
                }
            }
            .onChange(of: scrambleConfirmation) { _, flag in
                if play.transparent && !flag {
                    withAnimation {
                        play.transparent = false
                    }
                }
            }
        }
    }
}

#endif

