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
                Button {
                    if play.playing {
                        scrambleConfirmation = true
                    } else {
                        play.scramble()
                    }
                } label: {
                    Label("Scramble", systemImage: "shuffle")
                        .labelStyle(.titleAndIcon)
                }
                .padding()
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
        }
    }
}

#endif

