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
import SwiftUI

// MARK: - CaptureView.ViewModel

extension CaptureView {

    @MainActor
    @Observable
    class ViewModel {
        private let llmService: LLMServiceProtocol
        var selectedItem: PhotosPickerItem?
        var selectedImage: Image?

        var viewState: ViewState = .initial

        init(llmService: LLMServiceProtocol = MockLLMService()) {
            self.llmService = llmService
        }

        func analyze() async {
            guard let image = selectedImage else {
                return
            }
            viewState = .analyzing
            do {
                let analyzedResult = try await llmService.analyzeImage(image)
                viewState = .result(analyzedResult)
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
