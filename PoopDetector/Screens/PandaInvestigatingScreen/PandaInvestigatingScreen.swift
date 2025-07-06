//
//  PandaInvestigatingScreen.swift
//  PoopDetector
//
//  Created by Gokul Pulikkal on 7/6/25.
//

import SwiftUI

struct PandaInvestigatingScreen: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ZStack {
            Color.lightYellowBackground
                .ignoresSafeArea()

            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    Text("Investigating")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.brown)
                    Text(viewModel.currentLine)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.brown.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.currentLine)
                }

                HStack {
                    Image("analysingImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 240)
                    VStack {
                        Spacer()
                            .frame(height: 200)
                        PawPrintAnimation(isAnimating: $viewModel.isAnimating)
                    }
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            viewModel.startRotatingLines()
            viewModel.startAnimation()
        }
        .onDisappear {
            viewModel.stopRotatingLines()
            viewModel.stopAnimation()
        }
    }
}

#Preview {
    PandaInvestigatingScreen()
}
