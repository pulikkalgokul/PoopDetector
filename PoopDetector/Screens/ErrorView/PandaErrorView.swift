//
//  PandaErrorView.swift
//  PoopDetector
//
//  Created by Gokul Pulikkal on 7/6/25.
//

import SwiftUI

struct PandaErrorView: View {
    let title: String
    let subtitle: String
    var onRetry: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.brown)

                Text(subtitle)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundColor(.brown.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Image("confusedPanda")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)

            if let onRetry {
                Button(action: onRetry) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient.primaryButtonBackground
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Without Retry") {
    PandaErrorView(title: "No History Yet!", subtitle: "Start investigating")
}

#Preview("With Retry") {
    PandaErrorView(
        title: "Oh no!",
        subtitle: "This feature is not available now. Please contact support.",
        onRetry: {}
    )
    .background(Color.lightYellowBackground)
}
