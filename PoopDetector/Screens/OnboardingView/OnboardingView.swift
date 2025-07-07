//
//  OnboardingView.swift
//  PoopDetector
//
//  Created by Assistant on 7/6/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var viewModel = ViewModel()
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()
                Button("Skip") {
                    viewModel.skipOnboarding()
                    onComplete()
                }
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.brown.opacity(0.7))
                .padding()
                .opacity(viewModel.currentPage < viewModel.pages.count - 1 ? 1 : 0)
            }
                
            // Content
            TabView(selection: $viewModel.currentPage) {
                ForEach(viewModel.pages) { page in
                    OnboardingPageView(page: page)
                        .tag(page.id - 1)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
            // Bottom section
            VStack(spacing: 20) {
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0 ..< viewModel.pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == viewModel.currentPage ? Color.brown : Color.brown.opacity(0.3))
                            .frame(width: 10, height: 10)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
                    }
                }
                .padding(.bottom, 10)
                    
                // Action button
                Button(action: {
                    viewModel.nextPage()
                    if viewModel.isOnboardingCompleted {
                        onComplete()
                    }
                }) {
                    Text(currentButtonLabel)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(.brown)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient.primaryButtonBackground
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .background(
            Color.lightYellowBackground
                .ignoresSafeArea()
        )
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
    }
    
    private var currentButtonLabel: String {
        if viewModel.currentPage < viewModel.pages.count - 1 {
            return viewModel.pages[viewModel.currentPage].buttonLabel
        } else {
            return "Get Started"
        }
    }
}

#Preview("OnboardingView") {
    OnboardingView {
        print("Onboarding completed")
    }
}
