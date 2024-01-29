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
        static let version = 6

        let version: Int
        let cube: Cube
        let undoMoves: [Move]
        let redoMoves: [Move]
        let playing: Bool
        let tab: Int

        init(play: Play) {
            let undoMoves = play.undoItems.map { $0.move }
            let redoMoves = play.redoItems.map { $0.move }

            self.version = Self.version
            self.cube = play.cube
            self.undoMoves = undoMoves
            self.redoMoves = redoMoves
            self.playing = play.playing
            self.tab = play.tabSelection
        }

        func load(play: Play) {
            play.cube = cube
            play.undoItems = loadItems(moves: undoMoves, reverse: true)
            play.redoItems = loadItems(moves: redoMoves, reverse: false)
            play.playing = playing
            play.tabSelection = tab
        }

        private func loadItems(moves: [Move], reverse: Bool) -> [HistoryItem] {
            var cube = cube
            let items: [HistoryItem] = moves.reversed().reduce([]) { result, move in
                cube = cube.apply(move: reverse ? move.reversed : move)

                var newResult = result
                newResult.append(HistoryItem(cube: cube, move: move))
                return newResult
            }

            return items.reversed()
        }

        static var key: String {
            "Cube:\(version)"
        }
    }

    func save() throws {
        let data = SaveData(play: self)
        UserDefaults.standard.setValue(try JSONEncoder().encode(data), forKey: SaveData.key)
    }

    func load() throws {
        if let data = UserDefaults.standard.data(forKey: SaveData.key) {
            let saveData = try JSONDecoder().decode(SaveData.self, from: data)
            saveData.load(play: self)
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
