//
//  HistoryView.swift
//  Cube
//
//  Created by Basuke Suzuki on 1/14/24.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var play: Play

    var body: some View {
        ScrollView {
            Cube2DView(cube: play.cube.as2D(), scale: 2.0)

            ForEach(play.history.reversed()) { item in
                VStack {
                    Text(item.move.description)
                        .padding()
                    Cube2DView(cube: item.cube.as2D())
                }
            }
        }
        HStack {
            Button {
                play.undo(speed: .normal)
            } label: {
                Label("Undo", systemImage: "arrow.uturn.backward")
                    .labelStyle(.titleAndIcon)
            }
            .disabled(!play.canUndo)

            Button {
                play.redo(speed: .normal)
            } label: {
                Label("Redo", systemImage: "arrow.uturn.forward")
                    .labelStyle(.titleAndIcon)
            }
            .disabled(!play.canRedo)
        }
        .padding(.bottom)
    }
}

#Preview {
    HistoryView()
}
