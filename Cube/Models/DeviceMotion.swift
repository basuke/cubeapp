//
//  DeviceMotion.swift
//  Cube
//
//  Created by Basuke Suzuki on 8/30/23.
//

import CoreMotion

let kDeviceMotionUpdatesPerSecond = 10.0

class DeviceMotion: ObservableObject {
    private let manager = CMMotionManager()
    @Published var active = false

    @Published var pitch: Double = 0.0
    @Published var yaw: Double = 0.0
    @Published var roll: Double = 0.0

    init() {
        guard manager.isDeviceMotionAvailable else {
            active = false
            return
        }

        manager.deviceMotionUpdateInterval = 1.0 / kDeviceMotionUpdatesPerSecond
        manager.showsDeviceMovementDisplay = true
        manager.startDeviceMotionUpdates(to: .main) { motion, error in
            self.active = true

            if let error {
                print(error)
                return
            }

            if let motion {
                self.update(motion: motion)
            }
        }
    }

    private func update(motion: CMDeviceMotion) {
        let precision = 100.0
        let pitch = round(motion.attitude.pitch * precision) / precision
        let yaw = round(motion.attitude.yaw * precision) / precision
        let roll = round(motion.attitude.roll * precision) / precision

        if pitch != self.pitch {
            self.pitch = pitch
        }
        if yaw != self.yaw {
            self.yaw = yaw
        }
        if roll != self.roll {
            self.roll = roll
        }
    }
}
