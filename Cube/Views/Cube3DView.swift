//
//  Cube3DView.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/22/23.
//

import SwiftUI
import SceneKit

struct Cube3DView: View {
    @ObservedObject var play: Play

    struct SCNViewContainer: UIViewRepresentable {
        @ObservedObject var play: Play

        func makeUIView(context: Context) -> some UIView {
            let view = SCNView(frame: .zero)
            view.scene = play.scene
            return view
        }

        func updateUIView(_ uiView: UIViewType, context: Context) {
        }
    }

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                print("Changed: \(value)")
            }
            .onEnded { value in
                print("Ended: \(value)")
            }
    }

    var body: some View {
        SCNViewContainer(play: play)
            .gesture(dragGesture)
    }
}

#Preview {
    Cube3DView(play: Play())
}
