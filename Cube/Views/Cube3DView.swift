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
    @State var dragging: Dragging? = nil

    struct PlayViewContainer: UIViewRepresentable {
        @ObservedObject var play: Play
        let viewAdapter: ViewAdapter
        @Binding var yawRatio: Float

        func makeUIView(context: Context) -> some UIView {
            setCameraYaw()
            return viewAdapter.view
        }

        func updateUIView(_ uiView: UIViewType, context: Context) {
            setCameraYaw()
        }

        private func setCameraYaw() {
            play.forEachModel { $0.setCameraYaw(ratio: yawRatio) }
        }
    }

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard let dragging else {
                    dragging = viewAdapter.beginDragging(at: value.location, play: play) ?? VoidDragging()
                    return
                }

                dragging.update(at: value.location)
            }
            .onEnded { value in
                dragging?.end(at: value.location)
                dragging = nil
            }
    }

    var viewAdapter: ViewAdapter {
        play.viewAdapter(for: kind)
    }

    var body: some View {
        PlayViewContainer(play: play, viewAdapter: viewAdapter, yawRatio: $yawRatio)
            .gesture(dragGesture)
    }
}

#Preview {
    Cube3DView(play: Play(), kind: .sceneKit, yawRatio: .constant(1.0))
}
