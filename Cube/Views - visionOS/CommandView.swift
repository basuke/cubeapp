//
//  CommandView.swift
//  Cube
//
//  Created by Basuke Suzuki on 1/16/24.
//

import SwiftUI

struct CommandView: View {
    @EnvironmentObject private var play: Play

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
        TabView(selection: $play.tabSelection) {
            ScrollView {
                Text(howToPlay)
                    .padding()
            }
            .tabItem {
                Label("Help", systemImage: "book.fill")
            }
            .tag(0)

            MovesView()
                .disabled(!play.isInteractive)
                .tabItem {
                    Label("Keys", systemImage: "keyboard")
                }
                .tag(1)

            ScrollView {
                Text(credit)
                    .padding()
            }
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
            .tag(2)
        }
    }
}

#Preview {
    CommandView()
}
