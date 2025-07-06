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
                    Text("Scat Analysis")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.brown)

                    Text(entry.analyzedResult.scatDescription)
                        .font(.body)
                        .foregroundColor(.brown.opacity(0.8))
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Matching Animals")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.brown)

                    if let matchingAnimals = entry.matchingAnimals, !matchingAnimals.isEmpty {
                        ForEach(matchingAnimals, id: \.title) { animal in
                            AnimalMatchCard(animal: animal)
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
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ScanResultView(entry: ScanResultMockData.sampleAnalysisResult)
}
