//
//  AnimalMatchCard.swift
//  PoopDetector
//
//  Created by Gokul Pulikkal on 7/5/25.
//

import Foundation
import SwiftUI

struct AnimalMatchCard: View {
    let animal: WikiAPIResponseDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let imageURL = URL(string: animal.thumbnail.source) {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                        .frame(height: 200)
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(animal.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.brown)
                
                Text("About the Animal")
                    .font(.headline)
                    .foregroundColor(.brown)
                
                Text(animal.extract)
                    .font(.body)
                    .foregroundColor(.brown.opacity(0.8))
                    .lineLimit(6)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.9))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    AnimalMatchCard(animal: WikiAPIResponseDTO(
        title: "Red Fox",
        thumbnail: ImageInfoDTO(
            source: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c7/Fuchs_2016.jpg/320px-Fuchs_2016.jpg",
            width: 320,
            height: 213
        ),
        originalImage: ImageInfoDTO(
            source: "https://upload.wikimedia.org/wikipedia/commons/c/c7/Fuchs_2016.jpg",
            width: 1280,
            height: 853
        ),
        contentUrls: ContentURLInfoDTO(
            mobile: ReferenceDTO(
                page: "https://en.m.wikipedia.org/wiki/Red_fox"
            )
        ),
        extract: "The red fox (Vulpes vulpes) is the largest of the true foxes and one of the most widely distributed members of the order Carnivora. It is present across the entire Northern Hemisphere including most of North America, Europe and Asia, plus parts of North Africa. Red foxes are generalist predators that feed on small mammals, birds, reptiles, amphibians, fish, invertebrates, and various plant materials."
    ))
    .padding()
}
