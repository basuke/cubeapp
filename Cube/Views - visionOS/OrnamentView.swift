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
                    .padding(.trailing)
//                    .font(.title)

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
                .popover(isPresented: $scrambleConfirmation, arrowEdge: .bottom) {
                    Text("Are you sure?")
                        .padding()
                        .font(.title)
                    Text("Current playing cube will be destroyed.")
                        .padding()
                        .font(.subheadline)
                    Button("Do Scramble") {
                        scrambleConfirmation = false
                        play.scramble()
                    }
                    .padding()
                }
            }
            .padding()
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

