//
//  StickerComponent.swift
//  Cube
//
//  Created by Basuke Suzuki on 10/20/23.
//

import Foundation
import RealityKit

struct StickerComponent: Component, Codable {
    let color: Color

    init(color: Color) {
        self.color = color
    }
}

extension Entity {
    var color: Color? {
        if let component = components[StickerComponent.self] as StickerComponent? {
            component.color
        } else {
            nil
        }
    }
}
