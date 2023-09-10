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
    @State var dragging: Dragging?

    struct PlayViewContainer: UIViewRepresentable {
        @ObservedObject var play: Play
        @Binding var yawRatio: Float

        func makeUIView(context: Context) -> some UIView {
            play.models.forEach { $0.setCameraYaw(ratio: -yawRatio) }
            return play.view
        }

        func updateUIView(_ uiView: UIViewType, context: Context) {
            play.models.forEach { $0.setCameraYaw(ratio: -yawRatio) }
        }
    }

    func beginDragging(at location: CGPoint) -> Dragging? {
        guard let coordinator = play.coordinator else {
            return nil
        }

        return coordinator.beginDragging(at: location, play: play)
    }

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard let dragging else {
                    dragging = beginDragging(at: value.location) ?? VoidDragging()
                    return
                }

                dragging.update(at: value.location)
            }
            .onEnded { value in
                dragging?.end(at: value.location)
                dragging = nil
            }
    }

    var body: some View {
        PlayViewContainer(play: play, yawRatio: $yawRatio)
            .gesture(dragGesture)
    }
}
