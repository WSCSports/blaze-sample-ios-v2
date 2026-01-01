//
//  WidgetsListView.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 12/06/2025.
//

import SwiftUI

struct WidgetsListView: View {
    
    @EnvironmentObject private var coordinator: AppNavigationCoordinator
    
    let items: [ListItem] = [
        .init(title: "Stories row", subtitle: "A Blaze widget that displays stories in a horizontal row layout", route: .storiesRow),
        .init(title: "Stories grid", subtitle: "A Blaze widget that displays stories in a vertical grid layout", route: .storiesGrid),
        .init(title: "Moments row", subtitle: "A Blaze widget that displays moments in a horizontal row layout", route: .momentsRow),
        .init(title: "Moments grid", subtitle: "A Blaze widget that displays moments in a vertical grid layout", route: .momentsGrid),
        .init(title: "Videos row", subtitle: "A Blaze widget that displays videos in a horizontal row layout", route: .videoRow),
        .init(title: "Videos grid", subtitle: "A Blaze widget that displays videos in a vertical grid layout", route: .videoGrid),
        .init(title: "Widgets feed demo", subtitle: "An example of a feed with multiple widget types", route: .widgetsFeedDemo),
        .init(title: "Methods & Delegates", subtitle: "Demonstrates the different variations widget methods and custom delegates handlers", route: .methodsDelegates),
    ]
    
    var body: some View {
        ContenView
    }
    
    var ContenView: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Text("Explore available widgets")
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
        .navigationTitle("Widgets")
        .customBackButton()
    }
}

#Preview {
    NavigationView {
        WidgetsListView()
    }
}
