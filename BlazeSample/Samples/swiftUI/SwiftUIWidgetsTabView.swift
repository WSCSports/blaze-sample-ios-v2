//
//  SwiftUIWidgetsTabView.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 04/07/2025.
//

import SwiftUI

struct SwiftUIWidgetsTabView: View {
    
    @ObservedObject private var viewModel: SwiftUIWidgetsViewModel = .init()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SwiftUIWidgetsFeedView()
                .tabItem {
                    Image("widgets")
                    Text("Widgets Feed")
                }
                .tag(0)
            
            SwiftUIMomentsContainerView()
                .tabItem {
                    Image("moments_tab")
                    Text("Moments Container")
                }
                .tag(1)
        }
        .environmentObject(viewModel)
        .customBackButton()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("SwiftUI")
        .accentColor(.black)
        .toolbarBackground(Color(.systemBackground), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
    }
}

#Preview {
    SwiftUIWidgetsTabView()
} 
