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
        let action: () -> Void

        var holdGesture: some Gesture {
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if direction != bindingDirection {
                        action()
                        bindingDirection = direction
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
        let right: Bool
        let cancelAction: () -> Void

        var image: String {
            let dir = right ? "right" : "left"
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
                    cancelAction()
                    if let move = Move.from(string: move) {
                        play.apply(move: move)
                    }
                }
        }
    }

    struct ControllerView: View {
        @Binding var lookDirection: Direction?
        @Binding var right: Bool
        let cancelAction: () -> Void

        var body: some View {
            HStack {
                VStack {
                    Spacer()
                        .frame(height: width)
                    RotateButton(move: "z", right: right, cancelAction: cancelAction)
                    LookButton(direction: .left, bindingDirection: $lookDirection) {
                        cancelAction()
                        withAnimation {
                            right = false
                        }
                    }
                    RotateButton(move: "y'", right: right, cancelAction: cancelAction)
                    Spacer()
                        .frame(height: width)
                }
                .frame(width: width)

                Spacer()
                    .frame(width: width / 2)

                VStack {
                    let rightTransition : AnyTransition = .move(edge: .leading)
                        .combined(with: .scale)
                        .combined(with: .opacity)

                    let leftTransition : AnyTransition = .move(edge: .trailing)
                        .combined(with: .scale)
                        .combined(with: .opacity)

                    HStack {
                        if right {
                            RotateButton(move: "x'", right: true, cancelAction: cancelAction)
                                .transition(rightTransition)
                        }
                        LookButton(direction: .up, bindingDirection: $lookDirection) {
                            cancelAction()
                        }
                        if !right {
                            RotateButton(move: "x'", right: false, cancelAction: cancelAction)
                                .transition(leftTransition)
                        }
                    }
                    .frame(height: width)
                    Spacer()
                    HStack {
                        if right {
                            RotateButton(move: "x", right: true, cancelAction: cancelAction)
                                .transition(rightTransition)
                        }
                        LookButton(direction: .down, bindingDirection: $lookDirection) {
                            cancelAction()
                        }
                        if !right {
                            RotateButton(move: "x", right: false, cancelAction: cancelAction)
                                .transition(leftTransition)
                        }
                    }
                    .frame(height: width)
                }

                Spacer()
                    .frame(width: width / 2)

                VStack {
                    Spacer()
                        .frame(height: width)
                    RotateButton(move: "z'", right: right, cancelAction: cancelAction)
                    LookButton(direction: .right, bindingDirection: $lookDirection) {
                        cancelAction()
                        withAnimation {
                            right = true
                        }
                    }
                    RotateButton(move: "y", right: right, cancelAction: cancelAction)
                    Spacer()
                        .frame(height: width)
                }
                .frame(width: width)
            }
        }
    }
}

#endif
