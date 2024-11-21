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
                    initialState: .init(breeds: []),
                    imagesRepository: .live
                )
            )
            .tabItem {
                Label("Cats", systemImage: "cat.fill")
            }

            Text("Favorites")
                .tabItem {
                    Label("Favorites", systemImage: "star.fill")
                }
        }
    }
}

#Preview {
    AppView()
}
