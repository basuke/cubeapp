//
//  VolumetircView.swift
//  Cube
//
//  Created by Basuke Suzuki on 9/10/23.
//

import SwiftUI

struct VolumetircView: View {
    @ObservedObject var play: Play
    @State private var yawRatio: Float = 0.0

    var body: some View {
        RealityCubeView(play: play, yawRatio: $yawRatio)
    }
}

#Preview {
    VolumetircView(play: Play())
}
