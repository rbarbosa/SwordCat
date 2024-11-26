//
//  AppView.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import SwiftUI

struct AppView: View {

    let viewModel: AppViewModel

    var body: some View {
        contentView()
            .task {
                viewModel.send(.onAppear)
            }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func contentView() -> some View {
        if viewModel.state.isLoading {
            VStack {
                Text("Searching for cats...")
                ProgressView()
            }
        } else {
            tabView()
        }
    }

    private func tabView() -> some View {
        TabView {
            CatBreedsView(viewModel: viewModel.breedsViewModel)
                .tabItem {
                    Label("Cats", systemImage: "cat.fill")
                }

            CatBreedFavoritesView(viewModel: viewModel.favoritesViewModel)
                .tabItem {
                    Label("Favorites", systemImage: "star.fill")
                }
        }
    }
}

// MARK: - Previews

#Preview {
    AppView(
        viewModel: .init(
            initialState: .init(breeds: .init(), favorites: .init()),
            catBreedsRepository: .success,
            favoritesRepository: .success
        )
    )
}
