//
//  ScatAnalysisResultView.swift
//  PoopDetector
//
//  Created by Gokul P on 3/14/25.
//

import SwiftUI

struct ScatAnalysisResultView: View {
    var selectedImage: Image?
    var analysis: ScatAnalysis

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    if let selectedImage {
                        selectedImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150)
                            .cornerRadius(10)
                    }
                    Text(analysis.scatDescription)
                        .font(.body)
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(12)

                // Matching animals section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Matching Species")
                        .font(.headline)

                    ForEach(analysis.matchingAnimals, id: \.scientificName) { animal in
                        AnimalRowView(animal: animal)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    ScatAnalysisResultView(selectedImage: Image(systemName: "trash.fill"), analysis: ScatAnalysis(
        scatDescription: "The scat appears to be cylindrical and segmented, approximately 2-3 inches in length and dark brown in color. The droppings show visible plant matter and some fur content, suggesting an omnivorous diet. The scat is relatively fresh and has a characteristic tapered end.",
        matchingAnimals: [
            MatchingAnimal(
                animalName: "Black Bear",
                scientificName: "Ursus americanus"
            ),
            MatchingAnimal(
                animalName: "Coyote",
                scientificName: "Canis latrans"
            )
        ]
    ))
}
