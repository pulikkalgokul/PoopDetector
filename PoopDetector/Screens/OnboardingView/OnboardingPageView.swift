//
//  OnboardingPageView.swift
//  PoopDetector
//
//  Created by Gokul Pulikkal on 7/7/25.
//

import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 30) {
            // Image
            Image(page.image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 300)
                .padding(.horizontal, 20)

            // Text content
            VStack(spacing: 16) {
                Text(page.headline)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(.brown)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Text(page.body)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.brown.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 30)
            }
        }
        .padding(.vertical, 20)
    }
}

#Preview("OnboardingPageView") {
    OnboardingPageView(
        page: OnboardingPage(
            id: 1,
            image: "onboardingOne",
            headline: "Welcome to Detective Panda!",
            body: "Use your camera to scan animal scats in seconds and uncover who left them behind.",
            buttonLabel: "Let's Scan"
        )
    )
    .background(Color.lightYellowBackground)
}
