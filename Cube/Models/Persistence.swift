//
//  DataStore.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/13/23.
//

import Foundation

let kCubeDataKey = "cube_data"
let kCubeMovesKey = "cube_moves"

extension Play {
    func save() throws {
        UserDefaults.standard.setValue(try JSONEncoder().encode(cube), forKey: kCubeDataKey)
        UserDefaults.standard.setValue(try JSONEncoder().encode(moves), forKey: kCubeMovesKey)
    }

    func load() throws {
        if let data = UserDefaults.standard.data(forKey: kCubeDataKey) {
            cube = try JSONDecoder().decode(Cube.self, from: data)
        }

        if let data = UserDefaults.standard.data(forKey: kCubeMovesKey) {
            moves = try JSONDecoder().decode([Move].self, from: data)
        }

        rebuild()
    }
}
