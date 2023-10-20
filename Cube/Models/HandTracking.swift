//
//  HandTracking.swift
//  Cube
//
//  Created by Basuke Suzuki on 10/16/23.
//

#if os(visionOS)

import Foundation
import ARKit

class HandTracking: ObservableObject {
    private let session = ARKitSession()
    private let handTracking = HandTrackingProvider()
    private var monitoring = false

    @Published var hands: [HandAnchor.Chirality:HandAnchor] = [:]
    @Published var tracking = false

    func start() async {
        do {
            if HandTrackingProvider.isSupported {
                print("ARKitSession starting.")
                if !monitoring {
                    Task {
                        print("Start monitoring hand tracking.")
                        await publishHandTrackingUpdates()
                    }

                    Task {
                        print("Start monitoring session events.")
                        await monitorSessionEvents()
                    }
                    monitoring = true
                }
                try await session.run([handTracking])
                tracking = true
            }
        } catch {
            print("ARKitSession error:", error)
        }
    }

    public func stop() {
        session.stop()
    }

    private func publishHandTrackingUpdates() async {
        for await update in handTracking.anchorUpdates {
            let anchor = update.anchor
            // Publish updates only if the hand and the relevant joints are tracked.
            guard anchor.isTracked else { continue }

            let chirality = anchor.chirality

            print("hand: \(update.event) \(anchor)")
            switch update.event {
            case .updated, .added:
                // Update left hand info.
                hands[chirality] = anchor
            case .removed:
                hands.removeValue(forKey: chirality)
            }
        }
    }

    private func monitorSessionEvents() async {
        for await event in session.events {
            switch event {
            case .authorizationChanged(let type, let status):
                if type == .handTracking && status != .allowed {
                    // Stop the game, ask the user to grant hand tracking authorization again in Settings.
                }
            default:
                print("Session event \(event)")
            }
        }
    }
}

#endif
