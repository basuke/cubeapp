//
//  DataStore.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/13/23.
//

import Foundation

extension Play {
    struct SaveData: Codable {
        static let version = 1

        let version: Int
        let cube: Cube
        let moves: [Move]

        init(cube: Cube, moves: [Move]) {
            self.version = Self.version
            self.cube = cube
            self.moves = moves
        }

        static var key: String {
            "Cube:\(version)"
        }
    }

    func save() throws {
        let data = SaveData(cube: cube, moves: moves)
        UserDefaults.standard.setValue(try JSONEncoder().encode(data), forKey: SaveData.key)
    }

    func load() throws {
        if let data = UserDefaults.standard.data(forKey: SaveData.key) {
            let saveData = try JSONDecoder().decode(SaveData.self, from: data)
            cube = saveData.cube
            moves = saveData.moves
        }

        rebuild()
    }
}
