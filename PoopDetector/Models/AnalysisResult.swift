//
//  AnalysisResult.swift
//  PoopDetector
//
//  Created by Gokul P on 4/21/25.
//

import Foundation

struct AnalysisResult: Hashable {
    var id: UUID
    var timestamp: Date
    var imageData: Data?
    var analyzedResult: ScatAnalysisLLMResponse
    var matchingAnimals: [WikiAPIResponseDTO]? = []
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        imageData: Data? = nil,
        analyzedResult: ScatAnalysisLLMResponse,
        matchingAnimals: [WikiAPIResponseDTO]? = []
    ) {
        self.id = id
        self.timestamp = timestamp
        self.imageData = imageData
        self.analyzedResult = analyzedResult
        self.matchingAnimals = matchingAnimals
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}
