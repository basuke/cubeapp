//
//  DirectionComponent.swift
//  Cube
//
//  Created by Basuke Suzuki on 11/4/23.
//

import Foundation
import RealityKit

struct DirectionComponent: Component, Codable {
    let direction: Direction

    init(_ direction: Direction) {
        self.direction = direction
    }
}
