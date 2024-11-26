//
//  Helpers.swift
//  SwordCat
//
//  Created by Rui Barbosa on 26/11/2024.
//

import UIKit

#if DEBUG
func createMockImage(
    color: UIColor = .red,
    size: CGSize = CGSize(width: 100, height: 100)
) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
        color.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
}
#endif

