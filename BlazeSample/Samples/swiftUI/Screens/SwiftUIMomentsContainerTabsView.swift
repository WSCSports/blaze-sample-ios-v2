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
        }
    }
}

#Preview {
    SwiftUIMomentsContainerTabsView()
}
