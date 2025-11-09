//
//  SwiftUIMomentsContainerTabsView.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 23/09/2025.
//

import SwiftUI
import BlazeSDK

struct SwiftUIMomentsContainerTabsView: View {
    
    @EnvironmentObject var viewModel: SwiftUIWidgetsViewModel

    var body: some View {
        if let tabsContainer = viewModel.momentsPlayerContainerTabs {
            BlazeSwiftUIMomentsPlayerContainerTabsView(tabsContainer: tabsContainer)
                .onDisappear {
                    // Clean up container to prevent weak reference issues
                    viewModel.cleanupMomentsTabsContainer()
                }
        } else {
            Color.clear
                .onAppear {
                    // Create container when view appears
                    viewModel.setupMomentsTabsContainer()
                }
        }
    }
}

#Preview {
    SwiftUIMomentsContainerTabsView()
}
