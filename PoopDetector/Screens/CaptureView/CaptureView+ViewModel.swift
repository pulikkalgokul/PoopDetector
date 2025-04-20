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
        private let llmService: LLMServiceProtocol
        var selectedImage = UIImage()

        var viewState: ViewState = .initial
        var showPhotoPickerSheetWithCamera = false
        var showPhotoPickerSheet = false
        var modelContext: ModelContext?

        init(llmService: LLMServiceProtocol = MockLLMService()) {
            self.llmService = llmService
        }

        func analyze() async {
            viewState = .analyzing
            do {
                let analyzedResult = try await llmService.analyzeImage(selectedImage)
                viewState = .result(analyzedResult)
                modelContext?.insert(analyzedResult)
                try? modelContext?.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

enum ViewState {
    case initial
    case analyzing
    case result(ScatAnalysis)
    case failed(Error)
}
