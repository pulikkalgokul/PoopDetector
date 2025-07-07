//
//  View+NavigationTitle.swift
//  PoopDetector
//
//  Created by Assistant on 7/6/25.
//

import SwiftUI

extension View {
    func customNavigationTitle(_ title: String) -> some View {
        self
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(.brown)
                }
            }
    }
}

struct CustomNavigationTitleModifier: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(self.title)
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.brown)
                }
            }
    }
}
