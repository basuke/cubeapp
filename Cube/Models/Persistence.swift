//
//  DataStore.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/13/23.
//

import Foundation
import SwiftUI

extension Play {
    struct SaveData: Codable {
        static let version = 2

        let version: Int
        let cube: Cube
        let undoBuffer: [Move]
        let redoBuffer: [Move]

        init(cube: Cube, undoBuffer: [Move], redoBuffer: [Move]) {
            self.version = Self.version
            self.cube = cube
            self.undoBuffer = undoBuffer
            self.redoBuffer = redoBuffer
        }

        static var key: String {
            "Cube:\(version)"
        }
    }

    func save() throws {
        let data = SaveData(cube: cube, undoBuffer: moves, redoBuffer: undoneMoves)
        UserDefaults.standard.setValue(try JSONEncoder().encode(data), forKey: SaveData.key)
    }

    func load() throws {
        if let data = UserDefaults.standard.data(forKey: SaveData.key) {
            let saveData = try JSONDecoder().decode(SaveData.self, from: data)
            cube = saveData.cube
            moves = saveData.undoBuffer
            undoneMoves = saveData.redoBuffer
        }

        rebuild()
    }
}

extension View {
    func persistent(to play: Play) -> some View {
        self.modifier(PersistenceModifier(play: play))
    }
}

private struct PersistenceModifier: ViewModifier {
    let play: Play
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, phase in
                if phase == .inactive {
                    do {
                        try play.save()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
            .task {
                do {
                    try play.load()
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
    }
}
