//
//  PandaInvestigatingScreen+ViewModel.swift
//  PoopDetector
//
//  Created by Gokul Pulikkal on 7/6/25.
//

import Foundation

extension PandaInvestigatingScreen {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var currentLine = ""
        @Published var isAnimating = false
        
        private let funnyLines = [
            "Analyzing the evidence...",
            "Sniffing out the culprit...",
            "CSI: Crime Scene Investigation",
            "Consulting the poop database...",
            "Running DNA analysis...",
            "Interrogating suspects...",
            "Following the trail...",
            "Checking alibis...",
            "Dusting for paw prints...",
            "The plot thickens...",
            "Elementary, my dear Watson!",
            "Calling in the experts...",
            "Examining fiber evidence...",
            "Cross-referencing scat patterns...",
            "The truth is out there..."
        ]
        
        private var timer: Timer?
        private var currentIndex = 0
        
        init() {
            currentLine = funnyLines.first ?? ""
        }
        
        func startRotatingLines() {
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                Task { @MainActor in
                    self.currentIndex = (self.currentIndex + 1) % self.funnyLines.count
                    self.currentLine = self.funnyLines[self.currentIndex]
                }
            }
        }
        
        func stopRotatingLines() {
            timer?.invalidate()
            timer = nil
        }
        
        func startAnimation() {
            isAnimating = true
        }
        
        func stopAnimation() {
            isAnimating = false
        }
    }
}
