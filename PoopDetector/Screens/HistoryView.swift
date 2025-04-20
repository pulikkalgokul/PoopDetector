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
            if historyEntry.isEmpty {
                ContentUnavailableView(
                    "No Scans Yet",
                    systemImage: "magnifyingglass",
                    description: Text("Your scat analysis history will appear here")
                )
            } else {
                List(historyEntry) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.analyzedResult.scatDescription)
                            .font(.headline)
                        ForEach(entry.analyzedResult.matchingAnimals) { animal in
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
