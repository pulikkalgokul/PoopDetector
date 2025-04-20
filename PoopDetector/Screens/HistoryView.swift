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
    @Query(sort: \ScatAnalysis.timestamp, order: .reverse) private var scatAnalyses: [ScatAnalysis]

    var body: some View {
        NavigationView {
            if scatAnalyses.isEmpty {
                ContentUnavailableView("No Scans Yet",
                    systemImage: "magnifyingglass",
                    description: Text("Your scat analysis history will appear here"))
            } else {
                List(scatAnalyses) { analysis in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(analysis.scatDescription)
                            .font(.headline)
                        ForEach(analysis.matchingAnimals) { animal in
                            Text("• \(animal.animalName) (\(animal.scientificName))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .navigationTitle("Scat History")
            }
        }
    }
}

#Preview {
    HistoryView()
}
