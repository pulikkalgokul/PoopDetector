//
//  PandaInvestigatingScreen+ViewModel.swift
//  PoopDetector
//
//  Created by Gokul Pulikkal on 7/6/25.
//

import Foundation
import Observation

extension PandaInvestigatingScreen {
    @Observable
    @MainActor
    class ViewModel {
        var currentLine = ""
        var isAnimating = false
        
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
        
        private var rotatingTask: Task<Void, Never>?
        private var currentIndex = 0
        
        init() {
            currentLine = funnyLines.first ?? ""
        }
        
        func startRotatingLines() {
            rotatingTask?.cancel()
            rotatingTask = Task {
                while !Task.isCancelled {
                    currentIndex = (currentIndex + 1) % funnyLines.count
                    currentLine = funnyLines[currentIndex]
                    
                    do {
                        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                    } catch {
                        break
                    }
                }
            }
        }
        
        func stopRotatingLines() {
            rotatingTask?.cancel()
            rotatingTask = nil
        }
        
        func startAnimation() {
            isAnimating = true
        }
        
        func stopAnimation() {
            isAnimating = false
        }
    }
}
