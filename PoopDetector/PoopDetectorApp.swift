//
//  PoopDetectorApp.swift
//  PoopDetector
//
//  Created by Gokul P on 3/11/25.
//

import SwiftData
import SwiftUI

@main
struct PoopDetectorApp: App {
    @State private var showOnboarding = false
    
    init() {
        setupNavigationBarAppearance()
        checkOnboardingStatus()
    }
    
    var body: some Scene {
        WindowGroup {
            if showOnboarding {
                OnboardingView {
                    showOnboarding = false
                }
            } else {
                CaptureView()
            }
        }
        .modelContainer(for: HistoryEntry.self)
    }
    
    private func checkOnboardingStatus() {
        let onboardingCompleted = UserDefaults.standard.bool(forKey: "OnboardingCompleted")
        showOnboarding = !onboardingCompleted
    }
    
    private func setupNavigationBarAppearance() {
        // Transparent appearance (default)
        let transparentAppearance = UINavigationBarAppearance()
        transparentAppearance.configureWithTransparentBackground()
        transparentAppearance.backgroundColor = .clear
        transparentAppearance.backgroundEffect = nil
        transparentAppearance.shadowColor = .clear
        
        // Opaque appearance (when scrolling)
        let opaqueAppearance = UINavigationBarAppearance()
        opaqueAppearance.configureWithOpaqueBackground()
        opaqueAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        opaqueAppearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
        
        // Configure back button appearance for both
        let backButtonTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .heavy),
            .foregroundColor: UIColor.brown.withAlphaComponent(0.8)
        ]
        
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = backButtonTextAttributes
        
        // Apply to both appearances
        transparentAppearance.backButtonAppearance = buttonAppearance
        opaqueAppearance.backButtonAppearance = buttonAppearance
        
        // Apply to navigation bar
        UINavigationBar.appearance().standardAppearance = opaqueAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = transparentAppearance
        UINavigationBar.appearance().compactAppearance = opaqueAppearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = transparentAppearance
        
        // Set tint color for back arrow
        UINavigationBar.appearance().tintColor = UIColor.brown
    }
}
