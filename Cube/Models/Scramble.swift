//
//  Scramble.swift
//  Cube
//
//  Created by Basuke Suzuki on 1/18/24.
//

import SwiftUI

extension Play {
    func scramble() {
        reset()

        withAnimation {
            scrambling = true
            playing = true
        }

        undoItems = []
        redoItems = []

        for move in Move.random(count: 1, rotation: false) {
            apply(move: move, speed: .quick)
        }
    }
}
