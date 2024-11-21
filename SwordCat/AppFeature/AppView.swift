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
            Text("Cats breed list")
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
