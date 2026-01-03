//
//  LLMServiceProtocol.swift
//  PoopDetector
//
//  Created by Gokul P on 3/14/25.
//

import Foundation
import SwiftUI
import Mocking

enum LLMError: Error {
    case invalidResponse
    case apiError(String)
}

@Mocked(compilationCondition: .debug)
protocol LLMServiceProtocol: Sendable {
    func analyzeImage(_ image: UIImage) async throws -> ScatAnalysisLLMResponse
}
