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
                    ForEach(viewModel.state.favorites, id: \.id) { favorite in
                        Text(favorite.imageId)
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
}

// MARK: - Previews

#Preview {
    CatBreedFavoritesView(
        viewModel: .init(
            initialState: .init(favorites: []),
            repository: .live
        )
    )
}
