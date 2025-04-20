//
//  HistoryEntry.swift
//  PoopDetector
//
//  Created by Gokul P on 4/20/25.
//

import Foundation
import SwiftData

@Model
final class HistoryEntry {
    var id: UUID
    var timestamp: Date
    var imageData: Data?
    var analyzedResult: ScatAnalysis
    var wikiResponse: WikiResponse?
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        imageData: Data? = nil,
        analyzedResult: ScatAnalysis,
        wikiResponse: WikiResponse? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.imageData = imageData
        self.analyzedResult = analyzedResult
        self.wikiResponse = wikiResponse
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}
