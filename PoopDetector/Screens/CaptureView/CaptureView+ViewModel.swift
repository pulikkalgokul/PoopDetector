//
//  CaptureView+ViewModel.swift
//  PoopDetector
//
//  Created by Gokul P on 3/13/25.
//

import Foundation
import GoogleGenerativeAI
import Observation
import PhotosUI
import SwiftData
import SwiftUI

// MARK: - CaptureView.ViewModel

extension CaptureView {

    @MainActor
    @Observable
    class ViewModel {
        private let llmService: any LLMServiceProtocol
        private let wikiService: any WikiServiceProtocol
        var selectedImage = UIImage()

        var viewState: ViewState = .initial
        var navigationPath = NavigationPath()
        var showPhotoPickerSheetWithCamera = false
        var showPhotoPickerSheet = false
        var modelContext: ModelContext?

        init(
            llmService: any LLMServiceProtocol = MockLLMService(),
            wikiService: any WikiServiceProtocol = DefaultWikiService()
        ) {
            self.llmService = llmService
            self.wikiService = wikiService
        }

        func analyze() async {
            viewState = .analyzing
            do {
                let analyzedResultDTO = try await llmService.analyzeImage(selectedImage)
                let matchingAnimals = await getWikiStream(
                    animals: analyzedResultDTO.matchingAnimals
                )
                modelContext?.insert(
                    createHistoryEntry(
                        selectedImage: selectedImage,
                        analyzedResultDTO: analyzedResultDTO,
                        matchingAnimals: matchingAnimals
                    )
                )
                let analysisResult = AnalysisResult(analyzedResult: analyzedResultDTO, matchingAnimals: matchingAnimals)
                navigationPath.append(analysisResult)
            } catch {
                viewState = .failed(error)
            }
        }

        private func getWikiStream(
            animals: [MatchingAnimalsLLMResponse]
        ) async -> [WikiAPIResponseDTO] {
            var wikiResponses: [WikiAPIResponseDTO] = []
            for await (_, wiki) in wikiDataStream(for: animals) where wiki != nil {
                wikiResponses.append(wiki!)
            }
            return wikiResponses
        }

        private func createHistoryEntry(
            selectedImage: UIImage,
            analyzedResultDTO: ScatAnalysisLLMResponse,
            matchingAnimals: [WikiAPIResponseDTO]
        ) -> HistoryEntry {
            let scatAnalysis = ScatAnalysis(scatAnalysisDTO: analyzedResultDTO)
            let matchingAnimals = matchingAnimals.map { WikiResponse(wikiResponseDTO: $0) }
            return HistoryEntry(
                imageData: selectedImage.jpegData(compressionQuality: 0.8),
                analyzedResult: scatAnalysis,
                matchingAnimals: matchingAnimals
            )
        }

        func wikiDataStream(
            for animals: [MatchingAnimalsLLMResponse]
        ) -> AsyncStream<(
            MatchingAnimalsLLMResponse,
            WikiAPIResponseDTO?
        )> {
            AsyncStream { continuation in
                Task {
                    for animal in animals {
                        do {
                            let wikiAPIResponseDTO = try await wikiService.wikiData(for: animal.scientificName)
                            continuation.yield((animal, wikiAPIResponseDTO))
                        } catch {
                            continuation.yield((animal, nil))
                        }
                    }
                    continuation.finish()
                }
            }
        }
    }
}

enum ViewState {
    case initial
    case analyzing
    case failed(Error)
}
