//
//  MockLLMService.swift
//  PoopDetector
//
//  Created by Gokul P on 3/14/25.
//

import Foundation
import SwiftUI

actor MockLLMService: LLMServiceProtocol {
    func analyzeImage(_ image: UIImage) async throws -> ScatAnalysis {
        // Simulating network delay
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        
        return ScatAnalysis(
            scatDescription: "The scat appears to be cylindrical and segmented, approximately 2-3 inches in length and dark brown in color. The droppings show visible plant matter and some fur content, suggesting an omnivorous diet. The scat is relatively fresh and has a characteristic tapered end.",
            matchingAnimals: [
                MatchingAnimal(
                    animalName: "Black Bear",
                    scientificName: "Ursus americanus"
                ),
                MatchingAnimal(
                    animalName: "Coyote",
                    scientificName: "Canis latrans"
                )
            ]
        )
    }
}
