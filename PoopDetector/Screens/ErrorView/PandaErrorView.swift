//
//  PandaErrorView.swift
//  PoopDetector
//
//  Created by Gokul Pulikkal on 7/6/25.
//

import SwiftUI

struct PandaErrorView: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(spacing: 30) {
            Image("confusedPanda")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)

            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.brown)

                Text(subtitle)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundColor(.brown.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PandaErrorView(title: "No History Yet!", subtitle: "Start investigating")
}
