//
//  HistoryCard.swift
//  PoopDetector
//
//  Created by Gokul Pulikkal on 7/5/25.
//

import Foundation
import SwiftUI

struct HistoryCard: View {
    let entry: HistoryEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(entry.formattedDate)
                    .font(.caption)
                    .foregroundColor(.brown.opacity(0.7))
                Spacer()
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(.brown.opacity(0.7))
            }
            
            Text("Analysis Result")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.brown)
            
            Text(entry.analyzedResult.scatDescription)
                .font(.body)
                .foregroundColor(.brown.opacity(0.8))
                .lineLimit(3)
            
            if !entry.analyzedResult.matchingAnimals.isEmpty {
                Text("Matching Animals")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.brown)
                    .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(entry.analyzedResult.matchingAnimals) { animal in
                        HStack {
                            Circle()
                                .fill(Color.orange.opacity(0.6))
                                .frame(width: 6, height: 6)
                            Text("\(animal.animalName) (\(animal.scientificName))")
                                .font(.caption)
                                .foregroundColor(.brown.opacity(0.8))
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}
