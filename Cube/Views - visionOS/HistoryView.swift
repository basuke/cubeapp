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

    @Namespace var current

    var body: some View {
        ScrollViewReader { reader in
            ScrollView {
                LazyVStack {
                    ForEach(play.redoItems) { item in
                        VStack {
                            CubeView(cube: item.cube, selected: false)
                            Text(item.move.description)
                                .padding()
                        }
                    }
                    
                    CubeView(cube: play.cube, selected: true).id(current)
                    
                    ForEach(play.undoItems.reversed()) { item in
                        VStack {
                            Text(item.move.description)
                                .padding()
                            CubeView(cube: item.cube, selected: false)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.vertical)
        }
    }
}

#Preview {
    HistoryView() {
        
    }
}
