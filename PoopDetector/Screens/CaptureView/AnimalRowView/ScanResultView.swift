//
//  ScanResultView.swift
//  PoopDetector
//
//  Created by Gokul P on 4/20/25.
//

import SwiftUI

struct ScanResultView: View {
    let entry: AnalysisResult
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let imageData = entry.imageData,
               let uiImage = UIImage(data: imageData)
            {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(entry.formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(entry.analyzedResult.scatDescription)
                    .font(.body)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Matching Animals")
                    .font(.headline)

                if let matchingAnimals = entry.matchingAnimals, !matchingAnimals.isEmpty {
                    ForEach(matchingAnimals, id: \.title) { animal in
                        AnimalMatchCard(animal: animal)
                            .transition(.scale.combined(with: .opacity))
                    }
                } else {
                    Text("Searching for matching animals...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
    }
}

struct AnimalMatchCard: View {
    let animal: WikiAPIResponseDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(animal.title)
                .font(.headline)

            Text(animal.extract.description)
                .font(.subheadline)
                .lineLimit(3)

            if let imageURL = URL(string: animal.thumbnail.source) {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    ScanResultView(entry: ScanResultMockData.sampleAnalysisResult)
}
