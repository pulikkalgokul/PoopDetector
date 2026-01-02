//
//  PoopDetectorApp.swift
//  PoopDetector
//
//  Created by Gokul P on 3/11/25.
//

import FlagsmithClient
import SwiftData
import SwiftUI

@main
struct PoopDetectorApp: App {
    @AppStorage("OnboardingCompleted") private var onboardingCompleted: Bool = false
    @State private var showSplash = true
    
    init() {
        setupNavigationBarAppearance()
        setupFlagsmithClient()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                showSplash = false
                            }
                        }
                } else if !onboardingCompleted {
                    OnboardingView {
                        onboardingCompleted = true
                    }
                    .transition(.slideAway)
                } else {
                    CaptureView()
                        .transition(.slideAway)
                }
            }
            .animation(.easeIn, value: showSplash)
        }
        .modelContainer(for: HistoryEntry.self)
    }
    
    private func setupFlagsmithClient() {
        Flagsmith.shared.apiKey = "3EbDtQTSAUsTdRGHoRXCep"
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
