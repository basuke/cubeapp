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

    let callback: (Move) -> Void

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

    var body: some View {
        HStack {
            button("U")
            button("U", prime: true)
        }
        .buttonStyle(.bordered)
        .padding()
     }
}

#Preview {
    MoveController { move in
        print(move)
    }
}
