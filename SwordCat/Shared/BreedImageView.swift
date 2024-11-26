//
//  BreedImageView.swift
//  SwordCat
//
//  Created by Rui Barbosa on 25/11/2024.
//

import SwiftUI

struct BreedImageView: View {

    let state: ImageState

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 150, height: 150)

            switch state {
            case .loading:
                ProgressView()

            case .loaded(let uIImage):
                Image(uiImage: uIImage)
                    .resizable()

            case .error:
                Image(systemName: "exclamationmark.triangle")
            }
        }
        .contentShape(Rectangle())
        .frame(width: 150, height: 150)
    }
}

// MARK: - Previews

#Preview {
    BreedImageView(state: .loading)
}
