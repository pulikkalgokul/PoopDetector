//
//  LinearGradient+Extension.swift
//  PoopDetector
//
//  Created by Gokul Pulikkal on 7/5/25.
//

import Foundation
import SwiftUI

extension LinearGradient {
    /// Gradient used for primary action buttons
    static let primaryButtonBackground = LinearGradient(
        gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
        startPoint: .top,
        endPoint: .bottom
    )
}
