//
//  Scramble.swift
//  Cube
//
//  Created by Basuke Suzuki on 1/18/24.
//

import SwiftUI

extension Play {
    struct ScrambleConfiguration {
        let count: Int
        let rotation: Int
        let reset: Bool

        static let standard = Self(count: 15, rotation: 5, reset: false)
        static let debug = Self(count: 1, rotation: 0, reset: true)

    }

    func scramble(configuration: ScrambleConfiguration? = nil) {
        let configuration = configuration ?? (debug ? .debug : .standard)

        cancel()
        stopSpinning()

        withAnimation {
            scrambling = true
            playing = true

            if configuration.reset {
                cube = Cube()
                rebuild()
            }
        }

        undoItems = []
        redoItems = []

        for move in Move.random(count: configuration.count, rotation: configuration.rotation) {
            apply(move: move, speed: .quick)
        }

        solved = false
        celebrated = false
    }
}
