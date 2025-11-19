//
//  VideosInlineListView.swift
//  blaze-sample-ios-v2
//
//  Created by Cursor on 11/09/2025.
//

import SwiftUI

struct VideosInlineListView: View {
    
    @EnvironmentObject private var coordinator: AppNavigationCoordinator
    
    let items: [ListItem] = [
        .init(title: "Simple Feed", subtitle: "Basic auto-playing video feed", route: .simpleFeedExample),
        .init(title: "Advanced Paginating Feed", subtitle: "Advanced auto-playing video feed with infinite scroll and performance optimization", route: .videosFeed),
        .init(title: "Player Controls", subtitle: "Video player with programmatic controller", route: .playerControllerExample),
    ]
    
    var body: some View {
        ContenView
    }
    
    var ContenView: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Text("Explore inline video player integrations")
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
        .navigationTitle("Videos Inline")
        .accentColor(.black)
        .customBackButton()
    }
}

#Preview {
    NavigationView {
        VideosInlineListView()
    }
}

