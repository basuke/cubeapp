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
            .keyboardShortcut(shortcutKey, modifiers: [])
        }

        var shortcutKey: KeyEquivalent {
            KeyEquivalent(move[move.startIndex])
        }
    }

    func button(_ label: String) -> MoveButton {
        MoveButton(move: label) {
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
