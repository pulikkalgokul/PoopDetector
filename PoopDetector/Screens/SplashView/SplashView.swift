//
//  SplashView.swift
//  PoopDetector
//
//  Created by Gokul P on 7/15/25.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.lightYellowBackground
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image("splashImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .shadow(color: .brown.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Text("Poop Detective")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundColor(.brown)
                    .shadow(color: .brown.opacity(0.2), radius: 2, x: 0, y: 2)
            }
        }
    }
}

#Preview {
    SplashView()
}