//
//  DataStore.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/13/23.
//

import Foundation

let kCubeSaveDataVersion = 1
let kCubeSaveDataKey = "Cube:\(kCubeSaveDataVersion)"

extension Play {
    struct SaveData: Codable {
        let cube: Cube
        let moves: [Move]
    }

    func save() throws {
        let data = SaveData(cube: cube, moves: moves)
        UserDefaults.standard.setValue(try JSONEncoder().encode(data), forKey: kCubeSaveDataKey)
    }

    func load() throws {
        if let data = UserDefaults.standard.data(forKey: kCubeSaveDataKey) {
            let saveData = try JSONDecoder().decode(SaveData.self, from: data)
            cube = saveData.cube
            moves = saveData.moves
        }

        rebuild()
    }
}
