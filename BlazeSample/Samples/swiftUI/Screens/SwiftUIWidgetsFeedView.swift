//
//  SwiftUIWidgetsFeedView.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 04/07/2025.
//

import SwiftUI
import BlazeSDK

struct SwiftUIWidgetsFeedView: View {
    
    @EnvironmentObject var viewModel: SwiftUIWidgetsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerSection
                storiesRowSection
                momentsRowSection
                storiesGridSection
            }
            .padding(.top)
        }
        .onFirstAppear {
            viewModel.reloadData(progressType: .skeleton)
        }
        .refreshable {
            viewModel.reloadData(progressType: .skeleton)
        }
    }
    
    private var headerSection: some View {
        HStack {
            Text("Explore our different options and customizations, all built with SwiftUI.")
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var storiesRowSection: some View {
        section(title: "SwiftUI stories row") {
            BlazeSwiftUIStoriesRowWidgetView(viewModel: viewModel.storiesRowViewModel)
                .frame(height: 140)
        }
    }
    
    private var momentsRowSection: some View {
        section(title: "SwiftUI moments row") {
            BlazeSwiftUIMomentsRowWidgetView(viewModel: viewModel.momentsRowViewModel)
                .frame(height: 232)
        }
    }
    
    private var storiesGridSection: some View {
        section(title: "SwiftUI stories grid") {
            BlazeSwiftUIStoriesGridWidgetView(viewModel: viewModel.storiesGridViewModel)
        }
    }
    
    @ViewBuilder
    private func section(
        title: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.medium)
                Spacer()
            }
            .padding(.horizontal)
            
            content()
        }
        .padding(.bottom, 8)
    }
}

#Preview {
    SwiftUIWidgetsFeedView()
}
