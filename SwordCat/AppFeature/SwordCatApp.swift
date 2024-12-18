//
//  SwordCatApp.swift
//  SwordCat
//
//  Created by Rui Barbosa on 21/11/2024.
//

import SwiftUI

struct SwordCatApp: App {

    let viewModel: AppViewModel = .init(
        initialState: .init(breeds: .init(), favorites: .init()),
        catBreedsRepository: .live,
        favoritesRepository: .live
    )

    var body: some Scene {
        WindowGroup {
            AppView(viewModel: viewModel)
        }
    }
}

// MARK: - TestView

struct TestApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Running Unit Tests!")
        }
    }
}

@main
struct AppLauncher {
    static func main() {
        if NSClassFromString("XCTestCase") != nil {
            TestApp.main()
        } else {
            SwordCatApp.main()
        }
    }
}
