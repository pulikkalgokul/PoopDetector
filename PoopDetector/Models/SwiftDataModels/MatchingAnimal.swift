//
//  MatchingAnimal.swift
//  PoopDetector
//
//  Created by Gokul P on 3/14/25.
//

import Foundation
import SwiftData

@Model
final class MatchingAnimal: Decodable {
    
    @Relationship(deleteRule: .cascade, inverse: \ScatAnalysis.matchingAnimals)
    
    var animalName: String
    var scientificName: String

    init(animalName: String, scientificName: String) {
        self.animalName = animalName
        self.scientificName = scientificName
    }

    /// Decodable initializer
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.animalName = try container.decode(String.self, forKey: .animalName)
        self.scientificName = try container.decode(String.self, forKey: .scientificName)
    }

    private enum CodingKeys: String, CodingKey {
        case animalName
        case scientificName
    }
    
    init(matchingAnimalsDTO: MatchingAnimalsLLMResponse) {
        self.animalName = matchingAnimalsDTO.animalName
        self.scientificName = matchingAnimalsDTO.scientificName
    }
}
