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
                PandaErrorView(title: "No History Yet!", subtitle: "Start investigating")
            } else {
                ScrollView(showsIndicators: false) {
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
        .customNavigationTitle("Scat History")
    }
}

#Preview {
    HistoryView()
}
