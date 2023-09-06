//
//  ARKitModel.swift
//  Cube
//
//  Created by Basuke Suzuki on 9/5/23.
//

import Foundation
import RealityKit
import UIKit
import Combine

#if !os(xrOS)

class ARKitModel: RealityKitContent, Model {
    let arView = ARView(frame: .zero)

    init() {
        super.init(scene: arView.scene)
    }

    func hitTest(at location: CGPoint, cube: Cube) -> Sticker? {
        guard let result = arView.hitTest(location, query: .nearest).first else {
            return nil
        }

        let stickerEntity = result.entity
        guard let pieceEntity = stickerEntity.parent else {
            return nil
        }

        let stickerPosition = Vector(pieceEntity.convert(position: stickerEntity.position, to: cubeEntity))

        let position = (stickerPosition * 2).rounded * 0.5

        return cube.stickers.first { $0.position == position }
    }

    var view: UIView { arView }
}

#endif
