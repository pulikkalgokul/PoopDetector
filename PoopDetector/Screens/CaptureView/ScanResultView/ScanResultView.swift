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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(entry.analyzedResult.scatDescription)
                        .font(.body)
                        .foregroundColor(.brown.opacity(0.8))
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Matching Animals")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.brown)

                    if let matchingAnimals = entry.matchingAnimals, !matchingAnimals.isEmpty {
                        ForEach(matchingAnimals, id: \.title) { animal in
                            NavigationLink(destination: AnimalDetailView(animal: animal)) {
                                AnimalMatchCard(animal: animal)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .transition(.scale.combined(with: .opacity))
                        }
                    } else {
                        Text("Searching for matching animals...")
                            .font(.subheadline)
                            .foregroundColor(.brown.opacity(0.6))
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding(.horizontal)
        .background(Color.lightYellowBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: WikiAPIResponseDTO.self) { animal in
            AnimalDetailView(animal: animal)
        }
    }
}

#Preview {
    ScanResultView(entry: ScanResultMockData.sampleAnalysisResult)
}
