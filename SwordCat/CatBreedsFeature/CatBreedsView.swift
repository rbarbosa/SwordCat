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
        .sheet(item: viewModel.destinationBinding(for: \.detail)) { detailState in
            CatBreedDetailView(viewModel: .init(initialState: detailState))
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

                // TODO: - Add a progress view for the favoriting process
                Image(systemName: viewModel.state.isFavorite(breed) ? "star.fill" : "star")
                    .font(.system(size: 20))
                    .onTapGesture {
                        viewModel.send(.favoriteButtonTapped(breed))
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
}

// MARK: - Previews

#Preview {
    CatBreedsView(
        viewModel: .init(
            initialState: .init(),
            repository: .success,
            favoritesManager: .init(repository: .live, user: .init()),
            parentActionHandler: { _ in }
        )
    )
}
