//
//  LaunchView.swift
//  PoopDetector
//
//  Created by Gokul P on 3/14/25.
//

import SwiftUI

struct LaunchView: View {
    @State private var selectedTab = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            CaptureView()
                .tabItem {
                    Label("Home", systemImage: "camera")
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }
                .tag(1)
        }
    }
}

#Preview {
    LaunchView()
}
