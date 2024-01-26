//
//  MovesView.swift
//  Cube
//
//  Created by Basuke Suzuki on 1/20/24.
//

import SwiftUI

struct MovesView: View {
    enum Layout {
        case vertical, horizontal
    }

    struct MoveButton: View {
        let label: String
        @EnvironmentObject private var play: Play

        var body: some View {
            Button(label) {
                guard let move = Move.from(string: label) else {
                    fatalError("Invalid move \(label)")
                }

                play.cancel()
                play.apply(move: move)
            }
            .keyboardShortcut(shortcutKey, modifiers: modifiers)
            .buttonStyle(.bordered)
        }

        var shortcutKey: KeyEquivalent {
            KeyEquivalent(label[label.startIndex])
        }

        var modifiers: EventModifiers {
            isPrime ? [.shift] : []
        }

        var isPrime: Bool {
            label.hasSuffix("'")
        }
    }

    struct MoveButtons: View {
        let label: String
        let layout: Layout

        var body: some View {
            if layout == .vertical {
                VStack {
                    MoveButton(label: label.move(for: .up))
                    MoveButton(label: label.move(for: .down))
                }
            } else {
                HStack {
                    MoveButton(label: label.move(for: .left))
                    MoveButton(label: label.move(for: .right))
                }
            }
        }
    }

    struct TurnButtons: View {
        var body: some View {
            VStack {
                HStack {
                    MoveButtons(label: "L'", layout: .vertical)
                    VStack {
                        MoveButtons(label: "U", layout: .horizontal)
                        MoveButtons(label: "F'", layout: .horizontal)
                        MoveButtons(label: "D'", layout: .horizontal)
                    }
                    MoveButtons(label: "R", layout: .vertical)
                }
                Divider().frame(width:80)
                MoveButtons(label: "B", layout: .horizontal)
            }
        }
    }

    struct ExtraTurnButtons: View {
        var body: some View {
            HStack {
                MoveButtons(label: "E", layout: .vertical)
                MoveButtons(label: "M", layout: .vertical)
                MoveButtons(label: "S", layout: .vertical)
            }
        }
    }

    var body: some View {
        VStack {
            TurnButtons()
            Divider().frame(width:80)
            ExtraTurnButtons()
        }
    }
}

#Preview {
    MovesView()
}
