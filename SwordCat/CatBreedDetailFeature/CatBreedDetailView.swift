//
//  CatBreedDetailView.swift
//  SwordCat
//
//  Created by Rui Barbosa on 23/11/2024.
//

import SwiftUI

struct CatBreedDetailView: View {

    let viewModel: CatBreedDetailViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text(viewModel.state.breed.name)
                        .font(.largeTitle)
                        .padding()

                    GroupBox("Origin") {

                    }

                    GroupBox("Temperament") {
                        Text(viewModel.state.breed.temperament)
                            .padding(.top, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    GroupBox("Description") {
                        Text(viewModel.state.breed.description)
                            .padding(.top, 10)
                    }

                    favoriteButton()

                }
            }
            .navigationTitle("\(viewModel.state.breed.name) details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func favoriteButton() -> some View {
        Button {
            viewModel.send(.toggleFavorite)
        } label: {
            favoriteImage(isFavorite: viewModel.state.isFavorite)
                .font(.title)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
        }
        .padding(.top, 30)
        .padding(.horizontal, 20)
        .buttonStyle(.borderedProminent)
    }

    private func favoriteImage(isFavorite: Bool) -> some View {
        if isFavorite {
            Image(systemName: "heart.fill")
        } else {
            Image(systemName: "heart")
        }
    }
}

// MARK: - Previews

#Preview {
    CatBreedDetailView(
        viewModel: .init(
            initialState: .init(
                breed: .mock,
                isFavorite: true
            )
        )
    )
}
