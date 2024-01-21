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
        static let version = 3

        let version: Int
        let cube: Cube
        let undoMoves: [Move]
        let redoMoves: [Move]

        init(cube: Cube, undoMoves: [Move], redoMoves: [Move]) {
            self.version = Self.version
            self.cube = cube
            self.undoMoves = undoMoves
            self.redoMoves = redoMoves
        }

        static var key: String {
            "Cube:\(version)"
        }
    }

    func save() throws {
        let undoMoves = undoItems.map { $0.move }
        let redoMoves = redoItems.map { $0.move }
        let data = SaveData(cube: cube, undoMoves: undoMoves, redoMoves: redoMoves)
        UserDefaults.standard.setValue(try JSONEncoder().encode(data), forKey: SaveData.key)
    }

    func load() throws {
        if let data = UserDefaults.standard.data(forKey: SaveData.key) {
            let saveData = try JSONDecoder().decode(SaveData.self, from: data)
            cube = saveData.cube

            var undoCube = cube
            undoItems = saveData.undoMoves.reversed().reduce([]) { result, move in
                undoCube = undoCube.apply(move: move.reversed)
                var result = result
                result.append(HistoryItem(cube: undoCube, move: move))
                return result
            }

            undoItems.reverse()

            var redoCube = cube
            redoItems = saveData.redoMoves.reversed().reduce([]) { result, move in
                redoCube = redoCube.apply(move: move)
                var result = result
                result.append(HistoryItem(cube: redoCube, move: move))
                return result
            }

            redoItems.reverse()
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
