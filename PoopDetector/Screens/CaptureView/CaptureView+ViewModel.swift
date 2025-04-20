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
                if let matchingAnimal = analyzedResultDTO.matchingAnimals.first {
                    let wikiResponseDTO = try await wikiService.wikiData(for: matchingAnimal.scientificName)
                    modelContext?.insert(
                        createHistoryEntry(
                            selectedImage: selectedImage,
                            analyzedResultDTO: analyzedResultDTO,
                            wikiResponseDTO: wikiResponseDTO
                        )
                    )
                }
            } catch {
                print(error.localizedDescription)
            }
        }

        private func createHistoryEntry(
            selectedImage: UIImage,
            analyzedResultDTO: ScatAnalysisLLMResponse,
            wikiResponseDTO: WikiAPIResponseDTO
        ) -> HistoryEntry {
            let scatAnalysis = ScatAnalysis(scatAnalysisDTO: analyzedResultDTO)
            let wikiResponse = WikiResponse(wikiResponseDTO: wikiResponseDTO)
            return HistoryEntry(
                imageData: selectedImage.jpegData(compressionQuality: 0.8),
                analyzedResult: scatAnalysis,
                wikiResponse: wikiResponse
            )
        }
    }
}

enum ViewState {
    case initial
    case analyzing
    case result(ScatAnalysis)
    case failed(Error)
}
