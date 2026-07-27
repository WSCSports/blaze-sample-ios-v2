//
//  FollowEntitiesListView.swift
//  blaze-sample-ios-v2
//

import SwiftUI

struct FollowEntitiesListView: View {

    @EnvironmentObject private var coordinator: AppNavigationCoordinator

    let items: [ListItem] = [
        .init(title: "UIKit", subtitle: "Moments Follow Tabs widget built with UIKit", route: .followEntitiesUIKit),
        .init(title: "SwiftUI", subtitle: "Moments Follow Tabs widget built with SwiftUI", route: .followEntitiesSwiftUI),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Text("Explore the Follow Entities example")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                }
                .padding(.bottom, -8)

                ForEach(items) { item in
                    Button(action: {
                        coordinator.push(item.route)
                    }, label: {
                        ListItemView(item: item)
                    })
                }
            }
            .padding()
        }
        .navigationTitle("Follow Entities")
        .customBackButton()
    }
}

#Preview {
    NavigationView {
        FollowEntitiesListView()
    }
}
