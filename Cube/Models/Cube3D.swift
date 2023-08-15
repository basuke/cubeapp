//
//  Cube3D.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/14/23.
//

import Foundation
import SceneKit

struct Cube3D {
    let scene: SCNScene

    init(with cube: Cube) {
        // Create a scene
        scene = SCNScene()
        
        // Create a box geometry
        let boxGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        
        // Create a material with red color
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        // Assign the material to the box geometry
        boxGeometry.materials = [material]
        
        // Create a node with the box geometry
        let boxNode = SCNNode(geometry: boxGeometry)
        
        // Add the box node to the scene
        scene.rootNode.addChildNode(boxNode)
    }
}
