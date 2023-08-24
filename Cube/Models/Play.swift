//
//  Cube3D.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/14/23.
//

import Foundation
import SceneKit

enum TurnSpeed {
    case normal
    case quick

    var duration: TimeInterval {
        switch self {
        case .normal: 0.3
        case .quick: 0.1
        }
    }
}

class Play: ObservableObject {
    @Published var cube: Cube = Cube()
    @Published var moves: [Move] = []

    let view = SCNView(frame: .zero)
    let scene = SCNScene()
    let cubeNode = SCNNode()
    let cameraNode = SCNNode()
    let rotationNode = SCNNode()

    var running: Bool = false
    var requests: [Move] = []
    var pieceNodes: [SCNNode] = []

    var dragging: Dragging? = nil

    init() {
        view.scene = scene
        view.backgroundColor = .clear

        // Add the box node to the scene
        scene.rootNode.addChildNode(cubeNode)

        let camera = SCNCamera()
        camera.fieldOfView = 24.0
        camera.projectionDirection = .horizontal

        cameraNode.camera = camera
        cameraNode.position = SCNVector3(2.8, 8, 8)
        cameraNode.constraints = [SCNLookAtConstraint(target: cubeNode)]
        scene.rootNode.addChildNode(cameraNode)

        cubeNode.addChildNode(rotationNode)

        rebuild()
    }

    func rebuild() {
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

        pieceNodes.forEach { $0.removeFromParentNode() }
        pieceNodes = []

        // Create each piece
        let centers: [Float] = [-1, 0, 1]
        for z in centers {
            for y in centers {
                for x in centers {
                    if x != 0 || y != 0 || z != 0 {
                        let pieceNode = createPiece(Vector(x, y, z))
                        pieceNodes.append(pieceNode)
                        cubeNode.addChildNode(pieceNode)
                    }
                }
            }
        }
    }

    func apply(move: Move) {
        guard !running else {
            requests.append(move)
            return
        }

        running = true
        run(move: move)
    }

    private func run(move: Move, speed: TurnSpeed = .normal) {
        cube = cube.apply(move: move)

        movePiecesIntoRotation(for: move)

        let action = SCNAction.rotate(by: CGFloat(move.angle), around: SCNVector3(move.axis), duration: speed.duration)
        action.timingMode = .easeOut
        rotationNode.runAction(action) {
            DispatchQueue.main.async {
                self.afterAction()
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

    private func afterAction() {
        movePiecesBackFromRotation()

        if requests.isEmpty {
            running = false
        } else {
            let move = requests.removeFirst()
            run(move: move, speed: .quick)
        }
    }
}

extension SCNVector3 {
    init(_ vec: Vector) {
        self.init(vec.x, vec.y, vec.z)
    }
}

extension Vector {
    init(_ vec: SCNVector3) {
        self.init(vec.x, vec.y, vec.z)
    }

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

    var rounded: Self {
        Self(round(x), round(y), round(z))
    }
}

