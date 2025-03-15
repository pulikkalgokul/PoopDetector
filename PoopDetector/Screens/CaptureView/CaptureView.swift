//
//  CaptureView.swift
//  PoopDetector
//
//  Created by Gokul P on 3/14/25.
//

import PhotosUI
import SwiftUI

struct CaptureView: View {
    @State private var viewModel = ViewModel()
    var body: some View {
        switch viewModel.viewState {
        case .initial:
            initialView
        case .analyzing:
            ProgressView("Analyzing...")
        case let .result(analysis):
            ZStack {
                ScatAnalysisResultView(
                    selectedImage: viewModel.selectedImage!, analysis: analysis
                )
                VStack {
                    Spacer()
                    Button(action: {
                        viewModel.viewState = .initial
                    }, label: {
                        Label("Scan Again", systemImage: "repeat")
                            .bold()
                            .padding()
                            .foregroundStyle(.white)
                            .background(.indigo)
                            .clipShape(RoundedRectangle(cornerRadius: 20.0))
                    })
                }
            }
        case let .failed(error):
            Text(error.localizedDescription)
        }
    }

    var initialView: some View {
        VStack {
            Image("poopImage")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            Text("Let's Scan Some Shit")
                .font(.title)
            PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                Label("Select Photo", systemImage: "photo")
                    .bold()
                    .padding()
                    .foregroundStyle(.white)
                    .background(.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0))
            }
        }
        .onChange(of: viewModel.selectedItem) { _, newItem in
            Task {
                if let loadedImage = try? await newItem?.loadTransferable(type: Data.self),
                   let uimg = UIImage(data: loadedImage)
                {
                    viewModel.selectedImage = Image(uiImage: uimg)
                    await viewModel.analyze()
                }
            }
        }
    }
}

#Preview {
    CaptureView()
}
