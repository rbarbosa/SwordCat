//
//  CatBreedFavoritesView.swift
//  SwordCat
//
//  Created by Rui Barbosa on 22/11/2024.
//

import SwiftUI

struct CatBreedFavoritesView: View {

    let viewModel: CatBreedFavoritesViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(viewModel.state.favorites) { favorite in
                        breedCard(favorite)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.send(.onAppear)
            }
        }
    }

    // MARK: - Subviews

    private func breedCard(_ breed: Breed) -> some View {
        HStack(alignment: .top) {
            image(for: breed)

            VStack(alignment: .leading, spacing: 20) {
                Text(breed.name)
                    .font(.title2)

                // TODO: - Add a progress view for the favoriting process
//                Image(systemName: viewModel.state.isFavorite(breed) ? "star.fill" : "star")
//                    .font(.system(size: 20))
//                    .onTapGesture {
//                        viewModel.send(.favoriteButtonTapped(breed))
//                    }
            }
        }
        .onAppear {
//            viewModel.send(.onCardBreedAppear(breed))
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
    CatBreedFavoritesView(
        viewModel: .init(
            initialState: .init(favoritesFetched: []),
            repository: .live
        )
    )
}
