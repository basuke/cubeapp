//
//  Drag.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/22/23.
//

import Foundation
import SceneKit

class Dragging {
    let play: Play

    init(at location: CGPoint, play: Play) {
        self.play = play
        print("begin at \(location)")
    }

    func update(at location: CGPoint) {
        print("update at \(location)")
    }

    func end(at location: CGPoint) {
        print("end at \(location)")
    }
}

extension Play {
    func updateDragging(at location: CGPoint) {
        if let dragging {
            dragging.update(at: location)
        } else {
            dragging = Dragging(at: location, play: self)
        }
    }

    func endDragging(at location: CGPoint) {
        dragging?.end(at: location)
        dragging = nil
    }
}
