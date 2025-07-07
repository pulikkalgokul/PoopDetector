//
//  GeminiService.swift
//  PoopDetector
//
//  Created by Gokul P on 3/14/25.
//

import Foundation
import SwiftUI
@preconcurrency import GoogleGenerativeAI

actor GeminiService: LLMServiceProtocol {
    private let model: GenerativeModel
    
    init(apiKey: String) {
        self.model = GenerativeModel(name: "gemini-2.0-flash-exp", apiKey: apiKey, generationConfig: GenerationConfig(responseMIMEType: "application/json"))
    }
    
    @MainActor
    func analyzeImage(_ image: UIImage) async throws -> ScatAnalysisLLMResponse {
        
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
        
        let response = try await model.generateContent(prompt, image)
        
        guard let jsonString = response.text else {
            throw LLMError.invalidResponse
        }
        
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode(ScatAnalysisLLMResponse.self, from: jsonData)
        } catch {
            throw LLMError.apiError("Failed to parse response: \(error.localizedDescription)")
        }
    }
}
