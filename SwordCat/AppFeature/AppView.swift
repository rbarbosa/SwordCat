//
//  AppView.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import SwiftUI

struct AppView: View {
    var body: some View {
        TabView {
            CatBreedsView(
                viewModel: .init(
                    initialState: .init(),
                    repository: .live
                )
            )
            .tabItem {
                Label("Cats", systemImage: "cat.fill")
            }

            CatBreedFavoritesView(
                viewModel: .init(
                    initialState: .init(
                        favoritesFetched: []
                    ),
                    repository: .live
                )
            )
            .tabItem {
                Label("Favorites", systemImage: "star.fill")
            }
        }
    }
}

// MARK: - Previews

#Preview {
    AppView()
}
