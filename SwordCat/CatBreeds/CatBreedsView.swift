//
//  CatBreedsView.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import SwiftUI

struct CatBreedsView: View {

    let viewModel: CatBreedsViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(viewModel.breeds, id: \.id) { breed in
                        breedCard(breed)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Cat breeds")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.send(.onAppear)
        }
    }

    // MARK: - Subviews

    private func breedCard(_ breed: Breed) -> some View {
        HStack(alignment: .top) {
            image(for: breed)

            VStack(alignment: .leading, spacing: 20) {
                Text(breed.name)
                    .font(.title2)

                Image(systemName: "star")
                    .font(.system(size: 20))
            }
        }
    }

    private func image(for breed: Breed) -> some View {
        AsyncImage(url: breed.url) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 6.0))
            } else if phase.error != nil {
                Image(systemName: "exclamationmark.triangle")
            } else {
                ProgressView()
            }
        }
        .frame(width: 150, height: 150)
    }
}

// MARK: - Previews

#Preview {
    CatBreedsView(
        viewModel: .init(
            initialState: .init(breeds: []),
            repository: .success
        )
    )
}
