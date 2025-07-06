//
//  AnimalDetailView.swift
//  PoopDetector
//
//  Created by Claude on 7/6/25.
//

import SwiftUI

struct AnimalDetailView: View {
    let animal: WikiAPIResponseDTO
    @State private var scrollOffset: CGFloat = 0
    
    private let imageHeight: CGFloat = 300
    private let minImageHeight: CGFloat = 120
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 0) {
                    stretchyImageHeader(geometry: geometry)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        animalTitleSection
                        animalDescriptionSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .background(Color.lightYellowBackground)
                }
            }
            .coordinateSpace(name: "scroll")
            .ignoresSafeArea(.container, edges: .top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.lightYellowBackground)
    }
    
    @ViewBuilder
    private func stretchyImageHeader(geometry: GeometryProxy) -> some View {
        GeometryReader { imageGeometry in
            let offset = imageGeometry.frame(in: .named("scroll")).minY
            let height = max(minImageHeight, imageHeight + (offset > 0 ? offset : 0))
            let yOffset = offset > 0 ? -offset : 0
            
            if let imageURL = URL(string: animal.originalImage.source) {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: height)
                        .clipped()
                        .offset(y: yOffset)
                        .overlay(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.clear,
                                    Color.black.opacity(0.3)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                } placeholder: {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: geometry.size.width, height: height)
                        .offset(y: yOffset)
                        .overlay(
                            ProgressView()
                                .tint(.brown)
                        )
                }
            } else {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: geometry.size.width, height: height)
                    .offset(y: yOffset)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.brown.opacity(0.6))
                    )
            }
        }
        .frame(height: imageHeight)
    }
    
    @ViewBuilder
    private var animalTitleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(animal.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.brown)
                .multilineTextAlignment(.leading)
            
            if let url = URL(string: animal.contentUrls.mobile.page) {
                Link(destination: url) {
                    HStack(spacing: 8) {
                        Image(systemName: "link")
                            .font(.caption)
                        Text("View on Wikipedia")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    @ViewBuilder
    private var animalDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.brown)
            
            Text(animal.extract)
                .font(.body)
                .foregroundColor(.brown.opacity(0.8))
                .lineSpacing(4)
                .padding(16)
                .background(Color.white.opacity(0.8))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        }
    }
    
    @ViewBuilder
    private func quickFactRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.brown)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.brown.opacity(0.7))
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    NavigationStack {
        AnimalDetailView(animal: WikiAPIResponseDTO(
            title: "Red Fox",
            thumbnail: ImageInfoDTO(
                source: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c7/Fuchs_2016.jpg/320px-Fuchs_2016.jpg",
                width: 320,
                height: 213
            ),
            originalImage: ImageInfoDTO(
                source: "https://upload.wikimedia.org/wikipedia/commons/c/c7/Fuchs_2016.jpg",
                width: 1280,
                height: 853
            ),
            contentUrls: ContentURLInfoDTO(
                mobile: ReferenceDTO(
                    page: "https://en.m.wikipedia.org/wiki/Red_fox"
                )
            ),
            extract: "The red fox (Vulpes vulpes) is the largest of the true foxes and one of the most widely distributed members of the order Carnivora. It is present across the entire Northern Hemisphere including most of North America, Europe and Asia, plus parts of North Africa. Red foxes are generalist predators that feed on small mammals, birds, reptiles, amphibians, fish, invertebrates, and various plant materials. They have a distinctive orange-red coat, black legs, ears and muzzle, and a white-tipped tail."
        ))
    }
}
