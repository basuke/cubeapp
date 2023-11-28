//
//  ControllerView.swift
//  Cube
//
//  Created by Basuke Suzuki on 11/28/23.
//

import SwiftUI
import RealityKit

#if os(visionOS)

struct ControllerView: View {
    @Binding var lookDirection: Direction?
    var onTap: () -> Void

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
            case .up: "chevron.up.circle"
            case .down: "chevron.down.circle"
            case .left: "chevron.left.circle"
            case .right: "chevron.right.circle"
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
            }
            .contentShape(.capsule)
            .hoverEffect()
            .gesture(holdGesture)
        }
    }

    var cancelGesture: some Gesture {
        TapGesture()
            .onEnded {
                onTap()
            }
    }

    var body: some View {
        let width = 100.0

        GeometryReader { proxy in
            HStack {
                LookButton(direction: .left, bindingDirection: $lookDirection)
                .frame(height: proxy.size.height - width)
                VStack {
                    LookButton(direction: .up, bindingDirection: $lookDirection)
                    Rectangle()
                        .fill(.clear)
                        .contentShape(.rect)
                        .frame(height: proxy.size.height - width)
                        .gesture(cancelGesture)
//                        .focusable(interactions: .activate)
                    LookButton(direction: .down, bindingDirection: $lookDirection)
                }
                .frame(width: proxy.size.width - width)
                LookButton(direction: .right, bindingDirection: $lookDirection)
                    .frame(height: proxy.size.height - width)
            }
            .font(.largeTitle)
        }
    }
}

#Preview {
    RealityCubeView()
}

#endif
