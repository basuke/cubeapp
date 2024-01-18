//
//  Scramble.swift
//  Cube
//
//  Created by Basuke Suzuki on 1/18/24.
//

import SwiftUI

extension Play {
    func scramble() {
        forEachModel { $0.reset() }

        scrambling = true
        undoItems = []
        redoItems = []

        print("scrable")

        for move in Move.random(count: 20) {
            print(move)
            apply(move: move, speed: .quick)
        }
    }
}
