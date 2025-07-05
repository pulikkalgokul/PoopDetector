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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let imageData = entry.imageData,
                   let uiImage = UIImage(data: imageData)
                {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 250)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(entry.formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.brown.opacity(0.7))
                    
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
                
                Text(animal.extract.description)
                    .font(.body)
                    .foregroundColor(.brown.opacity(0.8))
                    .lineLimit(6)
                
                if !animal.extract.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Fun Fact")
                            .font(.headline)
                            .foregroundColor(.brown)
                            .padding(.top, 8)
                        
                        Text("This animal's characteristics help identify it through scat analysis.")
                            .font(.subheadline)
                            .foregroundColor(.brown.opacity(0.7))
                            .padding()
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.9))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ScanResultView(entry: ScanResultMockData.sampleAnalysisResult)
}
