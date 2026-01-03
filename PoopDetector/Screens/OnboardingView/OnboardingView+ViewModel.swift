//
//  OnboardingView+ViewModel.swift
//  PoopDetector
//
//  Created by Assistant on 7/6/25.
//

import Foundation
import Observation

extension OnboardingView {
    @Observable
    @MainActor
    class ViewModel {
        var currentPage = 0
        var isOnboardingCompleted = false
        
        private let userDefaults = UserDefaults.standard
        private let onboardingCompletedKey = "OnboardingCompleted"
        
        var pages: [OnboardingPage] = [
            OnboardingPage(
                id: 1,
                image: "onboardingOne",
                headline: "Welcome to Detective Panda!",
                body: "Use your camera to scan animal scats in seconds and uncover who left them behind.",
                buttonLabel: "Let's Scan"
            ),
            OnboardingPage(
                id: 2,
                image: "onboardingTwo",
                headline: "Scan & Reveal",
                body: "Tap 'Scan' to analyze droppings, then watch Detective Panda tell you which animal made them.",
                buttonLabel: "Show Me"
            ),
            OnboardingPage(
                id: 3,
                image: "onboardingThree",
                headline: "Your Detective Logbook",
                body: "Tap 'History' to revisit every scan. Swipe through past finds—see the animal, date, and location of each discovery.",
                buttonLabel: "View History"
            )
        ]
        
        func nextPage() {
            if currentPage < pages.count - 1 {
                currentPage += 1
            } else {
                completeOnboarding()
            }
        }
        
        func skipOnboarding() {
            completeOnboarding()
        }
        
        private func completeOnboarding() {
            userDefaults.set(true, forKey: onboardingCompletedKey)
            isOnboardingCompleted = true
        }
        
        func checkOnboardingStatus() -> Bool {
            return userDefaults.bool(forKey: onboardingCompletedKey)
        }
    }
}

struct OnboardingPage: Identifiable {
    let id: Int
    let image: String
    let headline: String
    let body: String
    let buttonLabel: String
}