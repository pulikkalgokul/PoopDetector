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
        Group {
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
                            NavigationLink(destination: ScanResultView(entry: entry.asAnalysisResult)) {
                                HistoryCard(entry: entry)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color.lightYellowBackground)
        .navigationTitle("Scat History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    HistoryView()
}
