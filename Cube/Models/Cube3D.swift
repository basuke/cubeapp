//
//  Cube3D.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/14/23.
//

import Foundation
import SceneKit

struct Cube3D {
    let scene = SCNScene()
    let cubeNode = SCNNode()
    let pieceNodes: [SCNNode]

    init(with cube: Cube) {
        // Add the box node to the scene
        scene.rootNode.addChildNode(cubeNode)

        func createPiece(_ vec: Vector) -> SCNNode {
            let base = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
            base.firstMaterial?.diffuse.contents = UIColor(white: 0.1, alpha: 0.8)

            let piece = SCNNode(geometry: base)

            piece.position = SCNVector3(vec)
            return piece
        }

        // Create each piece
        let centers: [Float] = [-1, 0, 1]
        var nodes: [SCNNode] = []
        for z in centers {
            for y in centers {
                for x in centers {
                    if x != 0 || y != 0 || z != 0 {
                        let pieceNode = createPiece(Vector(x, y, z))
                        nodes.append(pieceNode)
                        cubeNode.addChildNode(pieceNode)
                    }
                }
            }
        }
        pieceNodes = nodes
    }
}

extension SCNVector3 {
    init(_ vec: Vector) {
        self.init(vec.x, vec.y, vec.z)
    }
}
