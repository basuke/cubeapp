//
//  MoveController.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/12/23.
//

import SwiftUI

struct MoveController: View {
    enum Layout {
        case vertical, horizontal
    }

    let canUndo: Bool
    let callback: (Move?) -> Void

    struct MoveButton: View {
        let move: String
        let action: () -> Void

        var body: some View {
            Button(move) {
                action()
            }
            .keyboardShortcut(shortcutKey, modifiers: modifiers)
        }

        var shortcutKey: KeyEquivalent {
            KeyEquivalent(move[move.startIndex])
        }

        var modifiers: EventModifiers {
            isPrime ? [.shift] : []
        }

        var isPrime: Bool {
            move.hasSuffix("'")
        }
    }

    func undo() {
        callback(nil)
    }

    func button(_ label: String, prime: Bool = false) -> MoveButton {
        let label = prime ? "\(label)'" : label

        return MoveButton(move: label) {
            if let move =  Move.from(string: label) {
                callback(move)
            } else {
                print("Invalid move string \(label)")
            }
        }
    }

    func pair(_ label: String, layout: Layout, primeFirst: Bool) -> some View {
        HStack {
            if layout == .vertical {
                VStack {
                    if primeFirst {
                        button(label, prime: true)
                    }
                    button(label)
                    if !primeFirst {
                        button(label, prime: true)
                    }
                }
            } else {
                if primeFirst {
                    button(label, prime: true)
                }
                button(label)
                if !primeFirst {
                    button(label, prime: true)
                }
            }
        }
    }

    var turnButtons: some View {
        VStack {
            HStack {
                pair("L", layout: .vertical, primeFirst: true)
                VStack {
                    pair("B", layout: .horizontal, primeFirst: false)
                    pair("U", layout: .horizontal, primeFirst: false)
                    pair("F", layout: .horizontal, primeFirst: true)
                    pair("D", layout: .horizontal, primeFirst: true)
                }
                pair("R", layout: .vertical, primeFirst: false)
            }
        }
    }

    var extraButtons: some View {
        HStack {
            pair("E", layout: .vertical, primeFirst: false)
            pair("M", layout: .vertical, primeFirst: false)
            pair("S", layout: .vertical, primeFirst: false)
        }
    }

    var rotateButtons: some View {
        HStack {
            VStack {
                button("x", prime: false)
                pair("z", layout: .horizontal, primeFirst: true)
                pair("y", layout: .horizontal, primeFirst: false)
                button("x", prime: true)
            }
        }
    }

    var body: some View {
        HStack {
            VStack {
                rotateButtons
                Divider().frame(width:120)
                extraButtons
            }
            Spacer()
            VStack {
                turnButtons
                Divider().frame(width: 80)
                Button("Undo") {
                    undo()
                }
                .disabled(!canUndo)
            }
        }
        .buttonStyle(.bordered)
        .padding()
     }
}

#Preview {
    MoveController(canUndo: false) { move in
        print(move)
    }
}
