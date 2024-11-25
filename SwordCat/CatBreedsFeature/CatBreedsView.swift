//
//  CatBreedsView.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import SwiftUI

struct CatBreedsView: View {

    let viewModel: CatBreedsViewModel

    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(viewModel.breeds, id: \.id) { breed in
                        breedCard(breed)
                            .onTapGesture {
                                viewModel.send(.breedCardTapped(breed))
                            }
                    }
                    // TODO: - Add last card with loading/error states
                    lastRow()
                }
                .padding(.horizontal)
            }
            .navigationTitle("Cat breeds")
            .navigationBarTitleDisplayMode(.inline)
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .searchPresentationToolbarBehavior(.avoidHidingContent)
        .sheet(
            item: viewModel.destinationBinding(for: \.detail)
        ) { viewModel in
            CatBreedDetailView(viewModel: viewModel)
        }
        .onChange(of: searchText) { oldValue, newValue in
            if oldValue != newValue {
                viewModel.send(.search(newValue))
            }
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

                if viewModel.state.isUpdatingFavoriteBreed(breed) {
                    ProgressView()
                } else {
                    HStack(spacing: 10) {
                        Image(systemName: viewModel.state.isFavorite(breed) ? "star.fill" : "star")
                            .font(.system(size: 20))
                            .onTapGesture {
                                viewModel.send(.favoriteButtonTapped(breed))
                            }

                        if viewModel.state.hasErrorFavoriteBreed(breed) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.send(.onCardBreedAppear(breed))
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

    @ViewBuilder
    private func lastRow() -> some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, alignment: .center)
        } else if viewModel.hasFetchingError {
            retryButton()
        }
    }

    private func retryButton() -> some View {
        VStack {
            Button {
                viewModel.send(.retryButtonTapped)
            } label: {
                Text("Retry")
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 2)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.state.isLoading)


            Text("Failed to fetch cat breeds")
                .font(.subheadline)
                .foregroundStyle(.red.opacity(0.9))
        }
    }
}

// MARK: - Previews

#Preview("Sucess") {
    CatBreedsView(
        viewModel: .init(
            initialState: .init(),
            repository: .success,
            favoritesManager: .init(repository: .live, user: .init()),
            parentActionHandler: { _ in }
        )
    )
}

#Preview("Failure") {
    CatBreedsView(
        viewModel: .init(
            initialState: .init(),
            repository: .failure,
            favoritesManager: .init(repository: .live, user: .init()),
            parentActionHandler: { _ in }
        )
    )
}

