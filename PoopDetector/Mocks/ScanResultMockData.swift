//
//  ScanResultMockData.swift
//  PoopDetector
//
//  Created by Gokul P on 7/5/25.
//

import Foundation
import UIKit

struct ScanResultMockData {
    static let sampleAnalysisResult = AnalysisResult(
        id: UUID(),
        timestamp: Date(),
        imageData: sampleImageData,
        analyzedResult: sampleScatAnalysisResponse,
        matchingAnimals: sampleWikiResponses
    )
    
    static let sampleScatAnalysisResponse = ScatAnalysisLLMResponse(
        scatDescription: "This appears to be cylindrical scat approximately 2-3 inches long with a tapered end. The texture appears fibrous with visible plant material and berry seeds. The color is dark brown with some lighter streaks. The consistency suggests a herbivorous diet rich in fruits and vegetation.",
        matchingAnimals: [
            MatchingAnimalsLLMResponse(
                animalName: "Black Bear",
                scientificName: "Ursus americanus"
            ),
            MatchingAnimalsLLMResponse(
                animalName: "Raccoon",
                scientificName: "Procyon lotor"
            )
        ]
    )
    
    static let sampleWikiResponses = [
        WikiAPIResponseDTO(
            title: "American black bear",
            thumbnail: ImageInfoDTO(
                source: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/01_Schwarzbär%2C_Ursus_americanus%2C_Weibchen_mit_Jungen.jpg/320px-01_Schwarzbär%2C_Ursus_americanus%2C_Weibchen_mit_Jungen.jpg",
                width: 320,
                height: 240
            ),
            originalImage: ImageInfoDTO(
                source: "https://upload.wikimedia.org/wikipedia/commons/0/08/01_Schwarzbär%2C_Ursus_americanus%2C_Weibchen_mit_Jungen.jpg",
                width: 2048,
                height: 1536
            ),
            contentUrls: ContentURLInfoDTO(
                mobile: ReferenceDTO(page: "https://en.m.wikipedia.org/wiki/American_black_bear")
            ),
            extract: "The American black bear is a medium-sized bear endemic to North America. It is the continent's smallest and most widely distributed bear species. Black bears are omnivores, with their diets varying greatly depending on season and location."
        ),
        WikiAPIResponseDTO(
            title: "Raccoon",
            thumbnail: ImageInfoDTO(
                source: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ed/Raccoon_%28Procyon_lotor%29_2.jpg/320px-Raccoon_%28Procyon_lotor%29_2.jpg",
                width: 320,
                height: 213
            ),
            originalImage: ImageInfoDTO(
                source: "https://upload.wikimedia.org/wikipedia/commons/e/ed/Raccoon_%28Procyon_lotor%29_2.jpg",
                width: 1024,
                height: 683
            ),
            contentUrls: ContentURLInfoDTO(
                mobile: ReferenceDTO(page: "https://en.m.wikipedia.org/wiki/Raccoon")
            ),
            extract: "The raccoon is a medium-sized mammal native to North America. It is the largest of the procyonid family, having a body length of 40 to 70 cm and a body weight of 5 to 26 kg. Raccoons are noted for their intelligence and dexterity."
        )
    ]
    
    static let sampleImageData: Data? = {
        let image = UIImage(systemName: "photo")
        return image?.pngData()
    }()
}