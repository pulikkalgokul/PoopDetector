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
                    PandaInvestigatingScreen()
                case let .failed(error):
                    PandaErrorView(title: "Oh no!", subtitle: error.localizedDescription)
                }
            }
            .background(Color.lightYellowBackground)
            .navigationDestination(for: AnalysisResult.self) { analysis in
                ScanResultView(entry: analysis)
            }
            .navigationBarTitleDisplayMode(.inline)
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
        .tint(.brown)
    }

    var initialView: some View {
        VStack(spacing: 40) {
            titleStack
            pandaView
            cameraButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: HistoryView()) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(.brown)
                }
            }
        }
    }

    var titleStack: some View {
        VStack {
            Text("Who Did the")
                .font(.system(size: 48, weight: .heavy, design: .rounded))
                .foregroundColor(.brown)
            Text("DooDoo?")
                .font(.system(size: 48, weight: .heavy, design: .rounded))
                .foregroundColor(.brown)
        }
    }

    var pandaView: some View {
        Image("pandaMain")
            .resizable()
            .scaledToFit()
            .frame(width: 300, height: 300)
    }

    var cameraButton: some View {
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
            Image(systemName: "camera.fill")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
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
}

#Preview {
    CaptureView()
}
