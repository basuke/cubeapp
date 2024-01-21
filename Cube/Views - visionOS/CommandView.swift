//
//  CommandView.swift
//  Cube
//
//  Created by Basuke Suzuki on 1/16/24.
//

import SwiftUI

struct CommandView: View {
    @EnvironmentObject private var play: Play
    @State private var scrambleConfirmation = false
    @State private var tabSelection = 0

    var body: some View {
        VStack {
            Text("Cube")
                .padding()
                .font(.largeTitle)

            Button("Scramble") {
                if play.playing {
                    scrambleConfirmation = true
                } else {
                    play.scramble()
                }
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

            Picker("Section", selection: $tabSelection) {
                Text("How to Play").tag(0)
                Text("About").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            Text("Value: \(tabSelection)")
            Spacer()
        }
    }
}

#Preview {
    CommandView()
}
