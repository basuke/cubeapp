//
//  RealityCubeView.swift
//  Cube
//
//  Created by Basuke Suzuki on 10/9/23.
//

import SwiftUI
import RealityKit

#if os(visionOS)

struct RealityCubeView: View {
    @EnvironmentObject var play: Play
#if targetEnvironment(simulator)
    let scale: Float = 0.05
#else
    let scale: Float = 0.05
#endif
    @State var directionStickerEntity: Entity?
    @State var right: Bool = true
    @State private var lookDirection: Direction?

    var model: RealityKitModel {
        guard let model = play.model(for: .realityKit) as? RealityKitModel else {
            fatalError("Cannot get RealityKitModel")
        }
        return model
    }

    var mainPanelLength: CGFloat = 560
    let sidePanelWidth: CGFloat = 320
    let sidePanelCornerRadius: CGFloat = 30
    let toolbarHeight: CGFloat = 80

    var body: some View {
        ZStack {
            // Base layer. Command pane | space | History view
            VStack {
                // Toolbar
                HStack {
                    HStack {
                        OrnamentView()
                            .padding(.leading)
                        Spacer()
                    }
                    .frame(width: mainPanelLength + sidePanelWidth)

                    // Undo / Redo
                    HStack(alignment: .center) {
                        Button {
                            play.undo(speed: .normal)
                            model.removeDirectionButtonEntity()
                        } label: {
                            Label("Undo", systemImage: "arrow.uturn.backward")
                                .labelStyle(.titleAndIcon)
                        }
                        .disabled(!play.canUndo)

                        Button {
                            play.redo(speed: .normal)
                            model.removeDirectionButtonEntity()
                        } label: {
                            Label("Redo", systemImage: "arrow.uturn.forward")
                                .labelStyle(.titleAndIcon)
                        }
                        .disabled(!play.canRedo)
                    }
                    .frame(width: sidePanelWidth)
                }
                .frame(width: mainPanelLength + sidePanelWidth * 2, height: toolbarHeight)

                // Supplemental area. Command pane | space | History pane
                HStack {
                    VStack {
                        CommandView()
                            .background()
                            .clipShape(RoundedRectangle(cornerRadius: sidePanelCornerRadius))
                            .clipped()
                            .padding([.horizontal, .bottom])
                    }
                    .frame(width: sidePanelWidth)

                    Rectangle()
                        .fill(.clear)
                        .frame(width: mainPanelLength)

                    VStack {
                        HistoryView()
                            .background()
                            .clipShape(RoundedRectangle(cornerRadius: sidePanelCornerRadius))
                            .clipped()
                            .padding([.horizontal, .bottom])
                    }
                    .frame(width: sidePanelWidth)
                }
            }

            // Main layer. Control buttons | 3D content
            ZStack {
                if play.canPlay {
                    CancelView {
                        dismissDirections()
                    }

                    ControllerView(lookDirection: $lookDirection, right: $right) {
                        dismissDirections()
                    }
                }

                RealityView { content in
                    let entity = model.entity

                    entity.transform = Transform(scale: [scale, scale, scale])
                    model.pitch = .pi / 4 - (.pi / 10)
                    model.yaw = -.pi / 8

                    content.add(entity)

                    if !play.playing {
                        play.startSpinning()
                    }

                    let material = SimpleMaterial(color: .blue, isMetallic: true)
                    let sphere = ModelEntity(mesh: MeshResource.generateSphere(radius: 1.5 * sqrtf(3.0)), materials: [material])
                    entity.addChild(sphere)

                    if debug {
                        sphere.components.set(OpacityComponent(opacity: 0.2))
                    } else {
                        sphere.components.set(OpacityComponent(opacity: 0))
                    }
                } update: { content in
                    model.updateCamera(direction: lookDirection)
                }
                .simultaneousGesture(directionButtonsGeasture)
                .opacity(play.transparent ? 0.0 : 1.0)
            }
            .frame(width: mainPanelLength, height: mainPanelLength)
        }
    }
}

#Preview {
    RealityCubeView()
        .environmentObject(Play())
}

#endif
