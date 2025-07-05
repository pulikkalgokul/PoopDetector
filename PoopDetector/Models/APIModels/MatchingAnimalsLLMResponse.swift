//
//  MatchingAnimalsLLMResponse.swift
//  PoopDetector
//
//  Created by Gokul P on 4/20/25.
//

import Foundation

struct MatchingAnimalsLLMResponse: Decodable, Hashable {
    var animalName: String
    var scientificName: String
}
