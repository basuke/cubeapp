//
//  CommandView.swift
//  Cube
//
//  Created by Basuke Suzuki on 1/16/24.
//

import SwiftUI

struct CommandView: View {
    var body: some View {
        VStack {
            Button("Scramble") {
                print("Scramble")
            }
            .padding()
            Spacer()
            Button("About Cube") {
                print("About")
            }
            .padding()
        }
    }
}

#Preview {
    CommandView()
}
