//
//  DataStore.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/13/23.
//

import Foundation

class DataStore: ObservableObject {
    @Published var cube: Cube = Cube()
    @Published var moves: [Move] = []

    func save() throws {
        let data = try JSONEncoder().encode(cube)
        UserDefaults.standard.setValue(data, forKey: "cube_data")
    }

    func load() throws {
        if let data = UserDefaults.standard.data(forKey: "cube_data") {
            cube = try JSONDecoder().decode(Cube.self, from: data)
        }
    }
}
