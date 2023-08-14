//
//  DataStore.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/13/23.
//

import Foundation

let kCubeDataKey = "cube_data"
let kCubeMovesKey = "cube_moves"

class DataStore: ObservableObject {
    @Published var cube: Cube = Cube()
    @Published var moves: [Move] = []

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
    }
}
