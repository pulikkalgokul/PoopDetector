//
//  FeatureFlagUseCase.swift
//  PoopDetector
//
//  Created on 2026-01-02.
//

import Foundation
import FlagsmithClient
import Mocking

// MARK: - Protocol

@Mocked(compilationCondition: .debug)
protocol FeatureFlagUseCaseProtocol: Sendable {
    func isEnabled(flagID: String) async -> Bool
}

// MARK: - Implementation

struct DefaultFeatureFlagUseCase: FeatureFlagUseCaseProtocol {
    
    func isEnabled(flagID: String) async -> Bool {
        return (try? await getFeatureFlag(flagID: flagID)) ?? false
    }

    private func getFeatureFlag(flagID: String) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            Flagsmith.shared.hasFeatureFlag(withID: flagID, forIdentity: nil) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

