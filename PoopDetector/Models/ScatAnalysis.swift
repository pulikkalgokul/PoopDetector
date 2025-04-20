//
//  ScatAnalysis.swift
//  PoopDetector
//
//  Created by Gokul P on 3/14/25.
//

import Foundation
import SwiftData

@Model
final class ScatAnalysis: Decodable {
    var scatDescription: String
    var matchingAnimals: [MatchingAnimal]
    var timestamp: Date

    init(scatDescription: String, matchingAnimals: [MatchingAnimal]) {
        self.scatDescription = scatDescription
        self.matchingAnimals = matchingAnimals
        self.timestamp = Date()
    }

    /// Decodable initializer
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.scatDescription = try container.decode(String.self, forKey: .scatDescription)
        self.matchingAnimals = try container.decode([MatchingAnimal].self, forKey: .matchingAnimals)
        self.timestamp = Date()
    }

    private enum CodingKeys: String, CodingKey {
        case scatDescription
        case matchingAnimals
    }
}
