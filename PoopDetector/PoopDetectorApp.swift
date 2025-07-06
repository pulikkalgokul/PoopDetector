//
//  PoopDetectorApp.swift
//  PoopDetector
//
//  Created by Gokul P on 3/11/25.
//

import SwiftData
import SwiftUI

@main
struct PoopDetectorApp: App {
    var body: some Scene {
        WindowGroup {
            CaptureView()
        }
        .modelContainer(for: HistoryEntry.self)
    }
}
