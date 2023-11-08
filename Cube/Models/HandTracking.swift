//
//  HandTracking.swift
//  Cube
//
//  Created by Basuke Suzuki on 10/16/23.
//

#if os(visionOS)

import Foundation
import ARKit
import RealityKit

struct HandPose {
    let chirality: HandAnchor.Chirality
}

class HandTracking: ObservableObject {
    private let handTracking = HandTrackingProvider()

    var providers: [DataProvider] {
        [handTracking]
    }

    @Published var hands: [HandAnchor.Chirality:Entity] = [:]

    func processUpdates(in container: Entity) async {
        for await update in handTracking.anchorUpdates {
            let anchor = update.anchor
            // Publish updates only if the hand and the relevant joints are tracked.
            guard anchor.isTracked,
                  let skeleton = anchor.handSkeleton else { continue }

            let chirality = anchor.chirality

            switch update.event {
            case .updated, .added:
                processEvent(in: container, chirality: chirality, skeleton: skeleton)
            case .removed:
                removeEvent(chirality: chirality)
            }
        }
    }

    func processEvent(in container: Entity, chirality: HandAnchor.Chirality, skeleton: HandSkeleton) {
        func getEntity() -> Entity {
            if let entity = hands[chirality] {
                return entity
            }

            let entity = Entity()
            hands[chirality] = entity
            container.addChild(entity)
            return entity
        }

        let entity = getEntity()
        
    }

    func removeEvent(chirality: HandAnchor.Chirality) {
        guard let entity = hands[chirality] else { return }

        entity.removeFromParent()
        hands.removeValue(forKey: chirality)
    }
}

#endif
