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

    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
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
        .onReceive(timer) { _ in
            if isAnimating {
                // Fade out all paws
                pawOpacities = [0, 0, 0, 0]
                // Fade in current paw
                pawOpacities[currentPaw] = 1.0
                // Move to next paw
                currentPaw = (currentPaw + 1) % 3
            }
        }
        .onDisappear {
            timer.upstream.connect().cancel()
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
