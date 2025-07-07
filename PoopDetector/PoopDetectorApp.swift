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
    init() {
        setupNavigationBarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            CaptureView()
        }
        .modelContainer(for: HistoryEntry.self)
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        // Configure back button appearance
        let backButtonAppearance = UIBarButtonItemAppearance()
        let backButtonTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .heavy),
            .foregroundColor: UIColor.brown
        ]
        backButtonAppearance.normal.titleTextAttributes = backButtonTextAttributes
        appearance.backButtonAppearance = backButtonAppearance
        
        // Configure bar button items
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = backButtonTextAttributes
        appearance.buttonAppearance = buttonAppearance
        
        // Apply to navigation bar
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        // Set tint color for back arrow
        UINavigationBar.appearance().tintColor = UIColor(red: 0.4, green: 0.2, blue: 0, alpha: 1)
    }
}
