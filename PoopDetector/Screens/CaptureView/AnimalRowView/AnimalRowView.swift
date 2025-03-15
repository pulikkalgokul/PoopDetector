//
//  AnimalRowView.swift
//  PoopDetector
//
//  Created by Gokul P on 3/14/25.
//

import SwiftUI

struct AnimalRowView: View {
    let animal: MatchingAnimal
    var body: some View {
        VStack(alignment: .leading) {
            Text(animal.animalName)
                .font(.title3)
                .bold()
            Text(animal.scientificName)
                .font(.subheadline)
                .italic()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    AnimalRowView(animal: .init(animalName: "Fox", scientificName: "FoxScientificName"))
}
