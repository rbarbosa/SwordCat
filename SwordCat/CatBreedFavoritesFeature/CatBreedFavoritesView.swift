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
            contentView()
                .navigationTitle("Favorites")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(item: viewModel.destinationBinding(for: \.detail)
                ) { viewModel in
                    CatBreedDetailView(viewModel: viewModel)
                }
        }
        .onAppear {
            viewModel.send(.onAppear)
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func contentView() -> some View {
        if viewModel.state.isLoading {
            VStack(spacing: 16) {
                HStack {
                    Text("Getting your favorites...")
                        .font(.title)

                    Image(systemName: "heart.fill")
                        .font(.title2)
                        .foregroundStyle(.red.opacity(0.9))
                        .symbolEffect(.pulse, options: .repeat(.continuous))
                }

                ProgressView()
            }

        } else {
            breedList()
        }
    }

    private func breedList() -> some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(viewModel.state.favorites) { favorite in
                    breedCard(favorite)
                        .onAppear {
                            viewModel.send(.breedCardAppeared(favorite))
                        }
                        .onTapGesture {
                            viewModel.send(.breedCardTapped(favorite))
                        }
                }
            }
            .padding(.horizontal)
        }
    }

    private func breedCard(_ breed: Breed) -> some View {
        HStack(alignment: .top) {
            imageCard(for: breed)

            VStack(alignment: .leading, spacing: 20) {
                Text(breed.name)
                    .font(.title2)

                HStack {
                    Text("Lifespan")

                    Text(breed.lifeSpan)
                }
                .font(.subheadline)
            }
        }
    }

    private func imageCard(for breed: Breed) -> some View {
        BreedImageView(state: viewModel.state.imageState(for: breed))
            .onTapGesture {
                viewModel.send(.breedCardTapped(breed))

            }
    }
}

// MARK: - Previews

#Preview {
    CatBreedFavoritesView(
        viewModel: .init(
            initialState: .init(),
            repository: .live,
            favoritesManager: .init(repository: .live, user: .init())
        )
    )
}
