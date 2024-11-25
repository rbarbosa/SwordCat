//
//  ImageCache.swift
//  SwordCat
//
//  Created by Rui Barbosa on 25/11/2024.
//

import Foundation
import UIKit

actor ImageCache {
    static let shared = ImageCache()

    private var cache: [URL: UIImage] = [:]

    func image(for url: URL) -> UIImage? {
        cache[url]
    }

    func setImage(_ image: UIImage, for url: URL) {
        cache[url] = image
    }
}
