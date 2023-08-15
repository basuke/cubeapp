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
            base.firstMaterial?.diffuse.contents = UIColor(white: 0.1, alpha: 1.0)

            let piece = SCNNode(geometry: base)

            cube.stickers.filter { sticker in
                sticker.position.on(piece: vec)
            }.forEach { sticker in
                piece.addChildNode(createSticker(on: sticker.face, color: sticker.color))
            }

            piece.position = SCNVector3(vec)
            return piece
        }

        func createSticker(on face: Face, color: Color) -> SCNNode {
            let base = SCNBox(width: 0.8, height: 0.8, length: 0.8, chamferRadius: 0.1)
            base.firstMaterial?.diffuse.contents = color.uiColor

            let piece = SCNNode(geometry: base)

            // Shift the box a little bit
            func shift(_ a: Face, _ b: Face) -> Float {
                let shift: Float = 0.1 + 0.02
                return face == a ? shift : face == b ? -shift : 0
            }
            piece.position = SCNVector3(shift(.right, .left), shift(.up, .down), shift(.front, .back))

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

extension Vector {
    // To check the sticker position is on the piece position
    func on(piece: Self) -> Bool {
        func onFace(_ a: Float, _ b: Float) -> Bool {
            a != b && (a * b) > 0
        }

        if piece.x == self.x && piece.y == self.y {
            return onFace(piece.z, self.z)
        }
        if piece.y == self.y && piece.z == self.z {
            return onFace(piece.x, self.x)
        }
        if piece.z == self.z && piece.x == self.x {
            return onFace(piece.y, self.y)
        }
        return false
    }
}
