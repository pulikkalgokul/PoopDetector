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
                VStack(spacing: 30) {
                    Image("confusedPanda")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)

                    VStack(spacing: 12) {
                        Text("No History Yet!")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundColor(.brown)
                        
                        Text("Start investigating")
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundColor(.brown.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
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
        .customNavigationTitle("Scat History")
    }
}

#Preview {
    HistoryView()
}
