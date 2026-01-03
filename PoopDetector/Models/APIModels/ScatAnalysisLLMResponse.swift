//
//  ScatAnalysisLLMResponse.swift
//  PoopDetector
//
//  Created by Gokul P on 4/20/25.
//

import Foundation

struct ScatAnalysisLLMResponse: Decodable, Hashable {
    var scatDescription: String
    var matchingAnimals: [MatchingAnimalsLLMResponse]
}
