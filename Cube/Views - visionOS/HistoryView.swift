//
//  HistoryView.swift
//  Cube
//
//  Created by Basuke Suzuki on 1/14/24.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var play: Play
    let cancelAction: () -> Void

    struct CubeView: View {
        let cube: Cube
        let selected: Bool

        var body: some View {
            let opacity = selected ? 0.7 : 0.5
            let scale = selected ? 2.0 : 1.0

            Cube2DView(cube: cube.as2D(), scale: scale)
                .opacity(opacity)
                .drawingGroup()
        }
    }

    var body: some View {
        ScrollViewReader { reader in
            if play.canPlay {
                HStack {
                    Button {
                        cancelAction()
                        play.undo(speed: .normal)
                        reader.scrollTo("current", anchor: .bottom)
                    } label: {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                            .labelStyle(.titleAndIcon)
                    }
                    .disabled(!play.canUndo)

                    Button {
                        cancelAction()
                        play.redo(speed: .normal)
                        reader.scrollTo("current", anchor: .top)
                    } label: {
                        Label("Redo", systemImage: "arrow.uturn.forward")
                            .labelStyle(.titleAndIcon)
                    }
                    .disabled(!play.canRedo)
                }
                .padding(.vertical)
            }

            ScrollView {
                ForEach(play.redoItems) { item in
                    VStack {
                        CubeView(cube: item.cube, selected: false)
                        Text(item.move.description)
                            .padding()
                    }
                }

                CubeView(cube: play.cube, selected: true).id("current")

                ForEach(play.undoItems.reversed()) { item in
                    VStack {
                        Text(item.move.description)
                            .padding()
                        CubeView(cube: item.cube, selected: false)
                    }
                }
            }
        }
    }
}

#Preview {
    HistoryView() {
        
    }
}
