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
            .navigationDestination(for: WikiAPIResponseDTO.self) { animal in
                AnimalDetailView(animal: animal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: HistoryView()) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title2)
                            .foregroundColor(.brown)
                    }
                }
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
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                Text("Who Did the")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.brown)
                Text("DooDoo?")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.brown)
            }

            Image("pandaMain")
                .resizable()
                .scaledToFit()
                .frame(width: 280, height: 280)

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
                HStack {
                    Image(systemName: "camera.fill")
                        .font(.title2)
                    Text("Detect the Scat!")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    LinearGradient.primaryButtonBackground
                )
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.lightYellowBackground)
    }
}

#Preview {
    CaptureView()
}
