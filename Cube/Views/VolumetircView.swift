//
//  VolumetircView.swift
//  Cube
//
//  Created by Basuke Suzuki on 9/10/23.
//

import SwiftUI

#if os(xrOS)

struct VolumetircView: View {
    @ObservedObject var play: Play

    var body: some View {
        RealityCubeView(play: play)
    }
}

#Preview {
    VolumetircView(play: Play())
}

#endif
