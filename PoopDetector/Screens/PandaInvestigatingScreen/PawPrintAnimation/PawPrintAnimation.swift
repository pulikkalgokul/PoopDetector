//
//  PawPrintAnimation.swift
//  PoopDetector
//
//  Created by Gokul Pulikkal on 7/6/25.
//

import Foundation
import SwiftUI

struct PawPrintAnimation: View {
    @Binding var isAnimating: Bool
    @State private var pawOpacities: [Double] = [0, 0, 0, 0]
    @State private var currentPaw = 0

    var body: some View {
        HStack(spacing: 30) {
            ForEach(0 ..< 2) { index in
                Image("foot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .opacity(pawOpacities[index])
                    .animation(.easeInOut(duration: 0.3), value: pawOpacities[index])
            }
        }
        .task {
            while true {
                if isAnimating {
                    pawOpacities = [0, 0, 0, 0]
                    pawOpacities[currentPaw] = 1.0
                    currentPaw = (currentPaw + 1) % pawOpacities.count
                }
                try? await Task.sleep(nanoseconds: 400_000_000)
            }
        }
    }
}

#Preview("PawPrintAnimation") {
    struct PreviewWrapper: View {
        @State private var isAnimating = true

        var body: some View {
            VStack(spacing: 20) {
                PawPrintAnimation(isAnimating: $isAnimating)
                    .padding()
                    .background(Color.lightYellowBackground)
                    .cornerRadius(10)

                Toggle("Animate", isOn: $isAnimating)
                    .padding()
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
