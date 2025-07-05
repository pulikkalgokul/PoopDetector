//
//  HistoryView.swift
//  PoopDetector
//
//  Created by Gokul P on 3/14/25.
//

import SwiftData
import SwiftUI

@MainActor
struct HistoryView: View {
    @Query(sort: \HistoryEntry.timestamp, order: .reverse) private var historyEntry: [HistoryEntry]

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if historyEntry.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.brown.opacity(0.6))
                        
                        Text("No Scans Yet")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.brown)
                        
                        Text("Your scat analysis history will appear here")
                            .font(.body)
                            .foregroundColor(.brown.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(historyEntry) { entry in
                                HistoryCard(entry: entry)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Scat History")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

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

#Preview {
    HistoryView()
}
