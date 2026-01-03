//
//  CaptureViewModelTests.swift
//  PoopDetectorTests
//
//  Created on 2026-01-03.
//

import Testing
import SwiftUI
import SwiftData
import Mocking
@testable import PoopDetector

@MainActor
@Suite("CaptureView.ViewModel Tests")
struct CaptureViewModelTests {

    // MARK: - Test Data Helpers

    private func createMockImage() -> UIImage {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }

    private func createMockScatAnalysisResponse() -> ScatAnalysisLLMResponse {
        ScatAnalysisLLMResponse(
            scatDescription: "Test scat description",
            matchingAnimals: [
                MatchingAnimalsLLMResponse(
                    animalName: "Black Bear",
                    scientificName: "Ursus americanus"
                ),
                MatchingAnimalsLLMResponse(
                    animalName: "Coyote",
                    scientificName: "Canis latrans"
                )
            ]
        )
    }

    private func createMockWikiResponse(for scientificName: String) -> WikiAPIResponseDTO {
        WikiAPIResponseDTO(
            title: scientificName,
            thumbnail: ImageInfoDTO(
                source: "https://example.com/thumbnail.jpg",
                width: 100,
                height: 100
            ),
            originalImage: ImageInfoDTO(
                source: "https://example.com/original.jpg",
                width: 500,
                height: 500
            ),
            contentUrls: ContentURLInfoDTO(
                mobile: ReferenceDTO(page: "https://example.com/page")
            ),
            extract: "Test extract for \(scientificName)"
        )
    }

    // MARK: - Initialization Tests

    @Test("ViewModel initializes with correct default values")
    func testInitialization() {
        let viewModel = CaptureView.ViewModel()

        #expect(viewModel.viewState == .initial)
        #expect(viewModel.navigationPath.count == 0)
        #expect(viewModel.showPhotoPickerSheetWithCamera == false)
        #expect(viewModel.showPhotoPickerSheet == false)
        #expect(viewModel.modelContext == nil)
    }

    @Test("ViewModel initializes with custom services")
    func testInitializationWithCustomServices() {
        let mockLLM = LLMServiceProtocolMock()
        let mockWiki = WikiServiceProtocolMock()
        let mockFeatureFlag = FeatureFlagUseCaseProtocolMock()

        let viewModel = CaptureView.ViewModel(
            llmService: mockLLM,
            wikiService: mockWiki,
            featureFlagUseCase: mockFeatureFlag
        )

        #expect(viewModel.viewState == .initial)
    }

    // MARK: - Feature Flag Tests

    @Test("analyze() fails when feature flag is disabled")
    func testAnalyzeFailsWhenFeatureFlagDisabled() async {
        let mockLLM = LLMServiceProtocolMock()
        let mockFeatureFlag = FeatureFlagUseCaseProtocolMock()
        mockFeatureFlag._isEnabled.implementation = .returns(false)

        let viewModel = CaptureView.ViewModel(
            llmService: mockLLM,
            featureFlagUseCase: mockFeatureFlag
        )
        viewModel.selectedImage = createMockImage()

        await viewModel.analyze()

        #expect(mockFeatureFlag._isEnabled.callCount == 1)
        #expect(mockLLM._analyzeImage.callCount == 0)
        #expect(mockFeatureFlag._isEnabled.lastInvocation == "llm_service_enabled")

        guard case .failed(let error) = viewModel.viewState else {
            Issue.record("Expected viewState to be .failed")
            return
        }

        #expect(error.localizedDescription == "This feature is not available now. Please contact support.")
    }


    // MARK: - Successful Analysis Tests

    @Test("analyze() succeeds with feature flag enabled")
    func testAnalyzeSucceedsWithFeatureFlagEnabled() async {
        let mockLLM = LLMServiceProtocolMock()
        let mockWiki = WikiServiceProtocolMock()
        let mockFeatureFlag = FeatureFlagUseCaseProtocolMock()

        mockFeatureFlag._isEnabled.implementation = .returns(true)
        let mockResponse = createMockScatAnalysisResponse()
        mockLLM._analyzeImage.implementation = .returns(mockResponse)
        mockWiki._wikiData.implementation = .returns(createMockWikiResponse(for: "Ursus americanus"))

        let viewModel = CaptureView.ViewModel(
            llmService: mockLLM,
            wikiService: mockWiki,
            featureFlagUseCase: mockFeatureFlag
        )
        viewModel.selectedImage = createMockImage()

        await viewModel.analyze()

        #expect(mockFeatureFlag._isEnabled.callCount == 1)
        #expect(mockLLM._analyzeImage.callCount == 1)
        #expect(mockWiki._wikiData.callCount == 2) // Called for each matching animal
        #expect(viewModel.navigationPath.count == 1)
    }


    @Test("analyze() transitions through analyzing state")
    func testAnalyzeTransitionsThroughAnalyzingState() async {
        let mockLLM = LLMServiceProtocolMock()
        let mockFeatureFlag = FeatureFlagUseCaseProtocolMock()

        mockFeatureFlag._isEnabled.implementation = .returns(true)
        mockLLM._analyzeImage.implementation = .returns(createMockScatAnalysisResponse())

        let viewModel = CaptureView.ViewModel(
            llmService: mockLLM,
            featureFlagUseCase: mockFeatureFlag
        )
        viewModel.selectedImage = createMockImage()

        // State should start as initial
        #expect(viewModel.viewState == .initial)

        // Start analysis - this will transition to .analyzing then to final state
        await viewModel.analyze()
        #expect(viewModel.viewState == .analyzing)
    }


    // MARK: - Error Handling Tests

    @Test("analyze() handles LLM service error", arguments: [LLMError.apiError("Test API Error"), LLMError.invalidResponse])
    func testAnalyzeHandlesLLMError(testError: LLMError) async {
        let mockLLM = LLMServiceProtocolMock()
        let mockFeatureFlag = FeatureFlagUseCaseProtocolMock()

        mockFeatureFlag._isEnabled.implementation = .returns(true)
        mockLLM._analyzeImage.implementation = .throws(testError)

        let viewModel = CaptureView.ViewModel(
            llmService: mockLLM,
            featureFlagUseCase: mockFeatureFlag
        )
        viewModel.selectedImage = createMockImage()

        await viewModel.analyze()

        guard case .failed(let error) = viewModel.viewState else {
            Issue.record("Expected viewState to be .failed")
            return
        }

        #expect(error is LLMError)
    }

    // MARK: - Wiki Service Tests

    @Test("wikiDataStream yields successful results")
    func testWikiDataStreamYieldsSuccessfulResults() async {
        let mockLLM = LLMServiceProtocolMock()
        let mockWiki = WikiServiceProtocolMock()

        let animals = [
            MatchingAnimalsLLMResponse(
                animalName: "Black Bear",
                scientificName: "Ursus americanus"
            ),
            MatchingAnimalsLLMResponse(
                animalName: "Coyote",
                scientificName: "Canis latrans"
            )
        ]

        mockWiki._wikiData.implementation = .returns(createMockWikiResponse(for: "Test"))

        let viewModel = CaptureView.ViewModel(llmService: mockLLM, wikiService: mockWiki)

        var results: [(MatchingAnimalsLLMResponse, WikiAPIResponseDTO?)] = []
        for await result in viewModel.wikiDataStream(for: animals) {
            results.append(result)
        }

        #expect(results.count == 2)
        #expect(results[0].1 != nil)
        #expect(results[1].1 != nil)
        #expect(mockWiki._wikiData.callCount == 2)
    }


    @Test("wikiDataStream handles errors gracefully")
    func testWikiDataStreamHandlesErrors() async {
        let mockLLM = LLMServiceProtocolMock()
        let mockWiki = WikiServiceProtocolMock()

        let animals = [
            MatchingAnimalsLLMResponse(
                animalName: "Black Bear",
                scientificName: "Ursus americanus"
            )
        ]

        mockWiki._wikiData.implementation = .throws(NSError(
            domain: "WikiError",
            code: 404,
            userInfo: [NSLocalizedDescriptionKey: "Not found"]
        ))

        let viewModel = CaptureView.ViewModel(llmService: mockLLM, wikiService: mockWiki)

        var results: [(MatchingAnimalsLLMResponse, WikiAPIResponseDTO?)] = []
        for await result in viewModel.wikiDataStream(for: animals) {
            results.append(result)
        }

        #expect(results.count == 1)
        #expect(results[0].1 == nil) // Should yield nil for error
        #expect(mockWiki._wikiData.callCount == 1)
    }


    @Test("wikiDataStream calls wiki service with correct scientific names")
    func testWikiDataStreamCallsWithCorrectNames() async {
        let mockLLM = LLMServiceProtocolMock()
        let mockWiki = WikiServiceProtocolMock()

        let animals = [
            MatchingAnimalsLLMResponse(
                animalName: "Black Bear",
                scientificName: "Ursus americanus"
            ),
            MatchingAnimalsLLMResponse(
                animalName: "Coyote",
                scientificName: "Canis latrans"
            )
        ]

        mockWiki._wikiData.implementation = .returns(createMockWikiResponse(for: "Test"))

        let viewModel = CaptureView.ViewModel(llmService: mockLLM, wikiService: mockWiki)

        var results: [(MatchingAnimalsLLMResponse, WikiAPIResponseDTO?)] = []
        for await result in viewModel.wikiDataStream(for: animals) {
            results.append(result)
        }

        #expect(mockWiki._wikiData.callCount == 2)
        #expect(mockWiki._wikiData.invocations.count == 2)
        #expect(mockWiki._wikiData.invocations[0] == "Ursus americanus")
        #expect(mockWiki._wikiData.invocations[1] == "Canis latrans")
    }


    // MARK: - Navigation Tests

    @Test("analyze() populates navigation path on success")
    func testAnalyzePopulatesNavigationPath() async {
        let mockLLM = LLMServiceProtocolMock()
        let mockWiki = WikiServiceProtocolMock()
        let mockFeatureFlag = FeatureFlagUseCaseProtocolMock()

        mockFeatureFlag._isEnabled.implementation = .returns(true)
        mockLLM._analyzeImage.implementation = .returns(createMockScatAnalysisResponse())
        mockWiki._wikiData.implementation = .returns(createMockWikiResponse(for: "Test"))

        let viewModel = CaptureView.ViewModel(
            llmService: mockLLM,
            wikiService: mockWiki,
            featureFlagUseCase: mockFeatureFlag
        )
        viewModel.selectedImage = createMockImage()

        #expect(viewModel.navigationPath.count == 0)

        await viewModel.analyze()

        #expect(viewModel.navigationPath.count == 1)
    }


    // MARK: - Integration Tests

    @Test("analyze() with multiple matching animals calls wiki service correctly")
    func testAnalyzeWithMultipleMatchingAnimals() async {
        let mockLLM = LLMServiceProtocolMock()
        let mockWiki = WikiServiceProtocolMock()
        let mockFeatureFlag = FeatureFlagUseCaseProtocolMock()

        mockFeatureFlag._isEnabled.implementation = .returns(true)

        let response = ScatAnalysisLLMResponse(
            scatDescription: "Test description",
            matchingAnimals: [
                MatchingAnimalsLLMResponse(
                    animalName: "Animal 1",
                    scientificName: "Species 1"
                ),
                MatchingAnimalsLLMResponse(
                    animalName: "Animal 2",
                    scientificName: "Species 2"
                ),
                MatchingAnimalsLLMResponse(
                    animalName: "Animal 3",
                    scientificName: "Species 3"
                )
            ]
        )

        mockLLM._analyzeImage.implementation = .returns(response)
        mockWiki._wikiData.implementation = .returns(createMockWikiResponse(for: "Test"))

        let viewModel = CaptureView.ViewModel(
            llmService: mockLLM,
            wikiService: mockWiki,
            featureFlagUseCase: mockFeatureFlag
        )
        viewModel.selectedImage = createMockImage()

        await viewModel.analyze()

        #expect(mockWiki._wikiData.callCount == 3)
        #expect(viewModel.navigationPath.count == 1)
    }


    @Test("analyze() with empty matching animals completes successfully")
    func testAnalyzeWithEmptyMatchingAnimals() async {
        let mockLLM = LLMServiceProtocolMock()
        let mockWiki = WikiServiceProtocolMock()
        let mockFeatureFlag = FeatureFlagUseCaseProtocolMock()

        mockFeatureFlag._isEnabled.implementation = .returns(true)

        let response = ScatAnalysisLLMResponse(
            scatDescription: "Test description",
            matchingAnimals: []
        )

        mockLLM._analyzeImage.implementation = .returns(response)

        let viewModel = CaptureView.ViewModel(
            llmService: mockLLM,
            wikiService: mockWiki,
            featureFlagUseCase: mockFeatureFlag
        )
        viewModel.selectedImage = createMockImage()

        await viewModel.analyze()

        #expect(mockWiki._wikiData.callCount == 0)
        #expect(viewModel.navigationPath.count == 1)
    }
}
