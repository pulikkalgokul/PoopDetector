//
//  CaptureView.swift
//  PoopDetector
//
//  Created by Gokul P on 3/14/25.
//

import PhotosUI
import SwiftUI

@MainActor
struct CaptureView: View {
    @Environment(\.modelContext) var modelContext
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            VStack {
                switch viewModel.viewState {
                case .initial:
                    initialView
                case .analyzing:
                    ProgressView("Analyzing...")
                case let .failed(error):
                    Text(error.localizedDescription)
                }
            }
            .navigationDestination(for: AnalysisResult.self) { analysis in
                ScanResultView(entry: analysis)
            }
        }
        .sheet(isPresented: $viewModel.showPhotoPickerSheet) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $viewModel.selectedImage)
        }
        .sheet(isPresented: $viewModel.showPhotoPickerSheetWithCamera) {
            ImagePicker(sourceType: .camera, selectedImage: $viewModel.selectedImage)
        }
        .onAppear {
            viewModel.modelContext = modelContext
        }
        .onChange(of: viewModel.selectedImage) { _, _ in
            Task {
                await viewModel.analyze()
            }
        }
        .onChange(of: viewModel.navigationPath) { _, newPath in
            if newPath.isEmpty {
                viewModel.viewState = .initial
            }
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
            Menu(content: {
                Button(action: {
                    viewModel.showPhotoPickerSheet = true
                }) {
                    Label("Choose from Library", systemImage: "photo.on.rectangle")
                }

                Button(action: {
                    viewModel.showPhotoPickerSheetWithCamera = true
                }) {
                    Label("Take Photo", systemImage: "camera")
                }
            }, label: {
                Label("Click", systemImage: "photo")
                    .bold()
                    .padding()
                    .foregroundStyle(.white)
                    .background(.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0))
            })
        }
    }
}

#Preview {
    CaptureView()
}
