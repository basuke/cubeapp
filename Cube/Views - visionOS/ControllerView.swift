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

    struct LookButton: View {
        let direction: Direction
        @Binding var bindingDirection: Direction?

        var holdGesture: some Gesture {
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if direction != bindingDirection {
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
            ZStack {
                Rectangle()
                    .fill(.clear)
                Label(label, systemImage: icon)
                    .labelStyle(.iconOnly)
                    .font(.largeTitle)
            }
            .contentShape(.capsule)
            .hoverEffect()
            .gesture(holdGesture)
        }
    }

    struct ControllerView: View {
        @Binding var lookDirection: Direction?

        var body: some View {
            HStack {
                VStack {
                    Spacer()
                        .frame(height: width)
                    LookButton(direction: .left, bindingDirection: $lookDirection)
                        .frame(width: width)
                    Spacer()
                        .frame(height: width)
                }
                .frame(width: width)

                VStack {
                    LookButton(direction: .up, bindingDirection: $lookDirection)
                        .frame(height: width)
                    Spacer()
                    LookButton(direction: .down, bindingDirection: $lookDirection)
                        .frame(height: width)
                }

                VStack {
                    Spacer()
                        .frame(height: width)
                    LookButton(direction: .right, bindingDirection: $lookDirection)
                    Spacer()
                        .frame(height: width)
                }
                .frame(width: width)
            }
        }
    }
}

#endif
