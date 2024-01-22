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

    var howToPlay: LocalizedStringKey {
        load("how-to-play")
    }

    var credit: LocalizedStringKey {
        load("credit")
    }

    func load(_ name: String) -> LocalizedStringKey {
        if let filepath = Bundle.main.path(forResource: name, ofType: "md") {
            do {
                let contents = try String(contentsOfFile: filepath)
                return LocalizedStringKey(contents)
            } catch {
            }
        }
        return "**Error:** Cannot read \(name).md from main bundle."
    }

    var body: some View {
        VStack {
            Text("Cube Real")
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
                Text("Help").tag(0)
                Text("About").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            ScrollView {
                if tabSelection == 0 {
                    Text(howToPlay)
                } else {
                    Text(credit)
                }
            }
            .frame(alignment: .leading)
            .padding(.horizontal)

            Spacer()
        }
    }
}

#Preview {
    CommandView()
}
