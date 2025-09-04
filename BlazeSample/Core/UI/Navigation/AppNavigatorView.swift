//
//  AppNavigatorView.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 10/06/2025.
//


import SwiftUI

struct AppNavigatorView<Factory: AppViewFactory>: View {
   
    @StateObject private var coordinator = AppNavigationCoordinator()
   
    private let viewFactory: Factory

    init(viewFactory: Factory) {
        self.viewFactory = viewFactory
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            viewFactory.makeView(for: .start)
                .navigationDestination(for: AppRoute.self) { route in
                    viewFactory.makeView(for: route)
                }
        }
        .environmentObject(coordinator)
    }
}
