//
//  SwiftUIMomentsContainerView.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 04/07/2025.
//

import SwiftUI
import BlazeSDK

struct SwiftUIMomentsContainerView: View {
    
    @EnvironmentObject var viewModel: SwiftUIWidgetsViewModel

    var body: some View {
        BlazeSwiftUIMomentsContainerView(blazeContainer: viewModel.momentsPlayerContainer)
    }
}

#Preview {
    SwiftUIMomentsContainerView()
} 
