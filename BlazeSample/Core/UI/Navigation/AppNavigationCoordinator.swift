//
//  AppNavigationCoordinator.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 10/06/2025.
//

import SwiftUI

final class AppNavigationCoordinator: ObservableObject {
    
    @Published var path = NavigationPath()

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func handleDeeplink(_ url: URL) {
    }
}
