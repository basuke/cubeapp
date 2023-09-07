//
//  Cube3DView.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/22/23.
//

import SwiftUI

struct Cube3DView: View {
    @ObservedObject var play: Play
    @Binding var yawRatio: Float

    struct PlayViewContainer: UIViewRepresentable {
        @ObservedObject var play: Play
        @Binding var yawRatio: Float

        func makeUIView(context: Context) -> some UIView {
            play.model?.setCameraYaw(ratio: yawRatio)
            return play.view
        }

        func updateUIView(_ uiView: UIViewType, context: Context) {
            play.model?.setCameraYaw(ratio: yawRatio)
        }
    }

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                play.updateDragging(at: value.location)
            }
            .onEnded { value in
                play.endDragging(at: value.location)
            }
    }

    var body: some View {
        PlayViewContainer(play: play, yawRatio: $yawRatio)
            .gesture(dragGesture)
    }
}
