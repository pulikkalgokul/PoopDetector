//
//  GeminiService.swift
//  PoopDetector
//
//  Created by Gokul P on 3/14/25.
//

import Foundation
import SwiftUI
import GoogleGenerativeAI

class GeminiService: LLMServiceProtocol {
    private let model: GenerativeModel
    
    init(apiKey: String) {
        self.model = GenerativeModel(name: "gemini-2.0-flash-exp", apiKey: apiKey)
    }
    
    @MainActor
    func analyzeImage(_ image: Image) async throws -> ScatAnalysis {
        let imageRenderer = ImageRenderer(content: image)
        imageRenderer.scale = 1.0
        
        guard let uiImage = imageRenderer.uiImage else {
            throw LLMError.invalidResponse
        }
        
        let prompt = """
        You are an expert in wildlife biology and animal tracking. Given an image of scat, analyze its characteristics such as size, shape, color, consistency, and contents (e.g., fur, seeds, bones). Then, return a JSON object following this structure:
        {
          "scatDescription": "<A detailed description of the scat, including size, shape, color, consistency, and any identifiable contents>",
          "matchingAnimals": [
            {
              "animalName": "<Common name of the most likely animal>",
              "scientificName": "<Scientific name of the most likely animal>"
            }
          ]
        }

        Consider regional wildlife when suggesting animals. Provide the most accurate matches based on known scat identification principles.
        """
        
        let response = try await model.generateContent(prompt, uiImage)
        
        guard let jsonString = response.text else {
            throw LLMError.invalidResponse
        }
        
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode(ScatAnalysis.self, from: jsonData)
        } catch {
            throw LLMError.apiError("Failed to parse response: \(error.localizedDescription)")
        }
    }
}
