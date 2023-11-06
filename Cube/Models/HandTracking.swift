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
    private let handTracking = HandTrackingProvider()

    var providers: [DataProvider] {
        [handTracking]
    }

    @Published var hands: [HandAnchor.Chirality:HandAnchor] = [:]
    @Published var tracking = false

    func processUpdates() async {
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
}

#endif
