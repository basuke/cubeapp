//
//  RealityKitModel.swift
//  Cube
//
//  Created by Basuke Suzuki on 9/6/23.
//

import Foundation
import RealityKit
import UIKit

#if os(xrOS)

class RealityKitModel: RealityKitContent, Model {
    var view: UIView {
        UIView(frame:.zero)
    }

    func hitTest(at: CGPoint, cube: Cube) -> Sticker? {
        return nil
    }
}

#endif

