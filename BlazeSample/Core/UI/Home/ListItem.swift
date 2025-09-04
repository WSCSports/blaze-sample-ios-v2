//
//  ListItem.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 10/06/2025.
//

import Foundation

struct ListItem: Identifiable {
    let id = UUID()
    let icon: String?
    let title: String
    let subtitle: String
    let route: AppRoute

    init(icon: String? = nil, title: String, subtitle: String, route: AppRoute) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.route = route
    }
}
