//
//  Cube3DView.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/22/23.
//

import SwiftUI

struct Cube3DView: View {
    @ObservedObject var play: Play
    let kind: ViewAdapterKind
    @Binding var yawRatio: Float
    @State var dragging: Dragging?

    var coordinator: ViewAdapter {
        play.coordinator(for: kind)
    }

    struct PlayViewContainer: UIViewRepresentable {
        @ObservedObject var play: Play
        let coordinator: ViewAdapter
        @Binding var yawRatio: Float

        func makeUIView(context: Context) -> some UIView {
            play.forEachModel { $0.setCameraYaw(ratio: -yawRatio) }
            return coordinator.view
        }

        func updateUIView(_ uiView: UIViewType, context: Context) {
            play.forEachModel { $0.setCameraYaw(ratio: -yawRatio) }
        }
    }

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard let dragging else {
                    dragging = coordinator.beginDragging(at: value.location, play: play) ?? VoidDragging()
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
        PlayViewContainer(play: play, coordinator: coordinator, yawRatio: $yawRatio)
            .gesture(dragGesture)
    }
}
