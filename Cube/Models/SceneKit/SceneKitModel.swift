//
//  SceneKitModel.swift
//  Cube
//
//  Created by Basuke Suzuki on 9/30/23.
//

import Foundation
import SceneKit
import Combine

class SceneKitModel: Model {
    let sceneView = SCNView(frame: .zero)
    let scene = SCNScene()
    let cubeNode = SCNNode()
    let yawNode = SCNNode()
    let pitchNode = SCNNode()
    let cameraNode = SCNNode()
    let rotationNode = SCNNode()

    var pieceNodes: [SCNNode] = []

    var view: UIView {
        sceneView
    }

    init() {
        sceneView.scene = scene
        sceneView.backgroundColor = .clear

        cubeNode.addChildNode(rotationNode)

        setupCamera()
    }

    func rebuild(with cube: Cube) {
        func createPiece(_ piece: Piece) -> SCNNode {
            let base = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
            base.firstMaterial?.diffuse.contents = UIColor(white: 0.1, alpha: 1.0)

            let node = SCNNode(geometry: base)

            for (face, color) in piece.colors {
                node.addChildNode(createSticker(on: face, color: color))
            }

            node.position = SCNVector3(piece.position)
            node.setKind(.piece)
            return node
        }

        func createSticker(on face: Face, color: Color) -> SCNNode {
            let base = SCNBox(width: 0.8, height: 0.8, length: 0.8, chamferRadius: 0.1)
            base.firstMaterial?.diffuse.contents = color.uiColor

            let node = SCNNode(geometry: base)

            // Shift the box a little bit
            func shift(_ a: Face, _ b: Face) -> Float {
                let shift: Float = 0.1 + 0.02
                return face == a ? shift : face == b ? -shift : 0
            }
            node.position = SCNVector3(shift(.right, .left), shift(.up, .down), shift(.front, .back))
            node.setKind(.sticker)
            return node
        }

        pieceNodes.forEach { $0.removeFromParentNode() }
        pieceNodes = cube.pieces.map { createPiece($0) }
        pieceNodes.forEach { cubeNode.addChildNode($0) }
    }

    func run(move: Move, duration: Double) -> Future<Void, Never> {
        movePiecesIntoRotation(for: move)

        let action = SCNAction.rotate(by: CGFloat(move.angle), around: SCNVector3(move.face.axis), duration: duration)
        action.timingMode = .easeOut

        return Future() { promise in
            self.rotationNode.runAction(action) {
                DispatchQueue.main.async {
                    self.movePiecesBackFromRotation()
                    promise(Result.success(()))
                }
            }
        }
    }

    private func movePiecesIntoRotation(for move: Move) {
        let predicate = move.filter
        let targetPieces = pieceNodes.filter { predicate(Vector($0.position)) }

        targetPieces.forEach { piece in
            piece.removeFromParentNode()
            piece.transform = cubeNode.convertTransform(piece.transform, to: rotationNode)
            rotationNode.addChildNode(piece)
        }
    }

    private func movePiecesBackFromRotation() {
        let targetPieces = rotationNode.childNodes

        targetPieces.forEach { piece in
            piece.removeFromParentNode()
            piece.transform = cubeNode.convertTransform(piece.transform, from: rotationNode)
            cubeNode.addChildNode(piece)

            piece.position = SCNVector3(Vector(piece.position).rounded)
        }
    }

    func hitTest(at location: CGPoint, cube: Cube) -> Sticker? {
        let options: [SCNHitTestOption : Any] = [
            .searchMode: SCNHitTestSearchMode.closest.rawValue,
        ]

        guard let result = sceneView.hitTest(location, options: options).first else {
            return nil
        }

        let normal = Vector(cubeNode.convertVector(result.worldNormal, from: nil)).rounded

        return identifySticker(from: result.node, cube: cube, normal: normal)
    }

    private func identifySticker(from node: SCNNode, cube: Cube, normal: Vector) -> Sticker? {
        guard let pieceNode = node.parent, node.kind == .sticker else {
            return nil
        }

        let position = Vector(pieceNode.position).rounded
        guard let piece = cube.piece(at: position) else {
            return nil
        }

        return piece.sticker(facing: normal)
    }
}

let kNodeKindKey = "cube:node-kind"

enum NodeKind: String, RawRepresentable {
    case piece, sticker
}

extension SCNNode {
    var kind: NodeKind? {
        guard let value = value(forKey: kNodeKindKey) as? String else {
            return nil
        }

        return NodeKind(rawValue: value)
    }

    func setKind(_ kind: NodeKind) {
        setValue(kind.rawValue, forKey: kNodeKindKey)
    }
}
