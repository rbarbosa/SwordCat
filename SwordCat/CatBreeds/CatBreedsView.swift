//
//  CatBreedsView.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import SwiftUI

struct CatBreedsView: View {
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    catCard()
                }
                .padding(.horizontal)
            }
            .navigationTitle("Cat breeds")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Subviews

    private func catCard() -> some View {
        HStack(alignment: .top) {
            // Image placeholder
            Rectangle()
                .fill(Color.blue)
                .frame(width: 100, height: 100)

            VStack(spacing: 20) {
                Text("Cat")
                    .font(.title2)

                Image(systemName: "star")
                    .font(.system(size: 20))
            }
        }
    }
}

// MARK: - Previews

#Preview {
    CatBreedsView()
}
