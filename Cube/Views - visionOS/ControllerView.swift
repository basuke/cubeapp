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
        let label: String
        let icon: String?
        let image: String?

        init(label: String, icon: String? = nil, image: String? = nil) {
            self.label = label
            self.icon = icon
            self.image = image
        }

        var body: some View {
            ZStack {
                Rectangle()
                    .fill(.clear)
                if let icon {
                    Label(label, systemImage: icon)
                        .labelStyle(.iconOnly)
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                } else if let image {
                    Label(label, image: image)
                        .labelStyle(.iconOnly)
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                }
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
            TransparentButton(label: label, icon: icon)
                .gesture(holdGesture)
        }
    }

    struct RotateButton: View {
        @EnvironmentObject var play: Play
        let move: String
        var left: Bool = false

        var image: String {
            let dir = left ? "left" : "right"
            return switch move {
            case "x": "x-cw-\(dir)"
            case "x'": "x-ccw-\(dir)"
            case "y": "y-cw-\(dir)"
            case "y'": "y-ccw-\(dir)"
            case "z": "z-cw-\(dir)"
            case "z'": "z-ccw-\(dir)"
            default: ""
            }
        }

        var label: String {
            "Rotate cube to \(move)"
        }

        var body: some View {
            TransparentButton(label: label, image: image)
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
            let left = opacity != 0.0
            HStack {
                VStack {
                    Spacer()
                        .frame(height: width)
                    RotateButton(move: "z", left: left)
                    LookButton(direction: .left, bindingDirection: $lookDirection) {
                        withAnimation {
                            opacity = 1.0
                        }
                    }
                    RotateButton(move: "y'", left: left)
                    Spacer()
                        .frame(height: width)
                }
                .frame(width: width)

                Spacer()
                    .frame(width: width / 2)

                VStack {
                    HStack {
                        if !left {
                            RotateButton(move: "x'", left: false)
                        }
                        LookButton(direction: .up, bindingDirection: $lookDirection)
                        if left {
                            RotateButton(move: "x'", left: true)
                        }
                    }
                    .frame(height: width)
                    Spacer()
                    HStack {
                        if !left {
                            RotateButton(move: "x", left: false)
                        }
                        LookButton(direction: .down, bindingDirection: $lookDirection)
                        if left {
                            RotateButton(move: "x", left: true)
                        }
                    }
                    .frame(height: width)
                }

                Spacer()
                    .frame(width: width / 2)

                VStack {
                    Spacer()
                        .frame(height: width)
                    RotateButton(move: "z'", left: left)
                    LookButton(direction: .right, bindingDirection: $lookDirection) {
                        withAnimation {
                            opacity = 0.0
                        }
                    }
                    RotateButton(move: "y", left: left)
                    Spacer()
                        .frame(height: width)
                }
                .frame(width: width)
            }
        }
    }
}

#endif
