//
//  ControllerView.swift
//  Cube
//
//  Created by Basuke Suzuki on 11/28/23.
//

import SwiftUI
import RealityKit

#if os(visionOS)

let width = 100.0

extension RealityCubeView {
    struct CancelView: View {
        var onTap: () -> Void

        var cancelGesture: some Gesture {
            TapGesture()
                .onEnded {
                    onTap()
                }
        }

        var body: some View {
            Rectangle()
                .fill(.clear)
                .contentShape(.rect)
                .gesture(cancelGesture)
        }
    }

    struct TransparentButton: View {
        let icon: String
        let label: String

        var body: some View {
            ZStack {
                Rectangle()
                    .fill(.clear)
                Label(label, systemImage: icon)
                    .labelStyle(.iconOnly)
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
            }
            .contentShape(.capsule)
            .hoverEffect()
        }
    }

    struct LookButton: View {
        let direction: Direction
        @Binding var bindingDirection: Direction?
        var action: (() -> Void)? = nil

        var holdGesture: some Gesture {
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if direction != bindingDirection {
                        bindingDirection = direction

                        if let action {
                            action()
                        }
                    }
                }
                .onEnded { value in
                    bindingDirection = nil
                }
        }

        var icon: String {
            switch direction {
            case .up: "chevron.down.circle"
            case .down: "chevron.up.circle"
            case .left: "chevron.right.circle"
            case .right: "chevron.left.circle"
            }
        }

        var label: String {
            "Sight from \(direction)"
        }

        var body: some View {
            TransparentButton(icon: icon, label: label)
                .gesture(holdGesture)
        }
    }

    struct RotateButton: View {
        @EnvironmentObject var play: Play
        let move: String
        var left: Bool = false

        var icon: String {
            switch move {
            case "x": "arrow.turn.\(left ? "left" : "right").up"
            case "x'": "arrow.turn.\(left ? "left" : "right").down"
            case "y": "arrow.turn.down.left"
            case "y'": "arrow.turn.down.right"
            case "z": "arrow.turn.up.right"
            case "z'": "arrow.turn.up.left"
            default: ""
            }
        }

        var label: String {
            "Rotate cube to \(move)"
        }

        var body: some View {
            TransparentButton(icon: icon, label: label)
                .onTapGesture {
                    if let move = Move.from(string: move) {
                        play.apply(move: move)
                    }
                }
        }
    }

    struct ControllerView: View {
        @Binding var lookDirection: Direction?
        @State private var opacity = 0.0

        var body: some View {
            HStack {
                VStack {
                    Spacer()
                        .frame(height: width)
                    RotateButton(move: "z")
                    LookButton(direction: .left, bindingDirection: $lookDirection) {
                        withAnimation {
                            opacity = 1.0
                        }
                    }
                    RotateButton(move: "y'")
                    Spacer()
                        .frame(height: width)
                }
                .frame(width: width)

                VStack {
                    HStack {
                        RotateButton(move: "x'", left: true)
                            .opacity(1.0 - opacity)
                        LookButton(direction: .up, bindingDirection: $lookDirection)
                        RotateButton(move: "x'", left: false)
                            .opacity(opacity)
                    }
                    .frame(height: width)
                    Spacer()
                    HStack {
                        RotateButton(move: "x", left: true)
                            .opacity(1.0 - opacity)
                        LookButton(direction: .down, bindingDirection: $lookDirection)
                        RotateButton(move: "x", left: false)
                            .opacity(opacity)
                    }
                    .frame(height: width)
                }

                VStack {
                    Spacer()
                        .frame(height: width)
                    RotateButton(move: "z'")
                    LookButton(direction: .right, bindingDirection: $lookDirection) {
                        withAnimation {
                            opacity = 0.0
                        }
                    }
                    RotateButton(move: "y")
                    Spacer()
                        .frame(height: width)
                }
                .frame(width: width)
            }
        }
    }
}

#endif
