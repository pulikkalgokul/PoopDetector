//
//  HistoryEntry.swift
//  PoopDetector
//
//  Created by Gokul P on 4/20/25.
//

import Foundation
import SwiftData

@Model
final class HistoryEntry {
    var id: UUID
    var timestamp: Date
    var imageData: Data?
    var analyzedResult: ScatAnalysis
    var matchingAnimals: [WikiResponse]? = []
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        imageData: Data? = nil,
        analyzedResult: ScatAnalysis,
        matchingAnimals: [WikiResponse]? = []
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
    
    var asAnalysisResult: AnalysisResult {
        // Convert ScatAnalysis to ScatAnalysisLLMResponse
        let scatAnalysisLLMResponse = ScatAnalysisLLMResponse(
            scatDescription: analyzedResult.scatDescription,
            matchingAnimals: analyzedResult.matchingAnimals.map { matchingAnimal in
                MatchingAnimalsLLMResponse(
                    animalName: matchingAnimal.animalName,
                    scientificName: matchingAnimal.scientificName
                )
            }
        )
        
        // Convert WikiResponse to WikiAPIResponseDTO
        let wikiAPIResponseDTOs = matchingAnimals?.map { wikiResponse in
            WikiAPIResponseDTO(
                title: wikiResponse.title,
                thumbnail: ImageInfoDTO(
                    source: wikiResponse.thumbnail.source,
                    width: wikiResponse.thumbnail.width,
                    height: wikiResponse.thumbnail.height
                ),
                originalImage: ImageInfoDTO(
                    source: wikiResponse.originalImage.source,
                    width: wikiResponse.originalImage.width,
                    height: wikiResponse.originalImage.height
                ),
                contentUrls: ContentURLInfoDTO(
                    mobile: ReferenceDTO(page: wikiResponse.contentUrls.mobile.page)
                ),
                extract: wikiResponse.extract
            )
        }
        
        return AnalysisResult(
            id: id,
            timestamp: timestamp,
            imageData: imageData,
            analyzedResult: scatAnalysisLLMResponse,
            matchingAnimals: wikiAPIResponseDTOs
        )
    }
}
