//
//  FollowEntitiesSwiftUIView.swift
//  blaze-sample-ios-v2
//

import SwiftUI
import BlazeSDK

/// SwiftUI counterpart to `FollowEntitiesViewController` — same tabs-backed Moments widget
/// (Trending / For You / Your Picks), personalized via followed entities.
struct FollowEntitiesSwiftUIView: View {

    @StateObject private var viewModel = FollowEntitiesSwiftUIViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Moments Follow Tabs")
                        .font(.title3)
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding(.horizontal)

                BlazeSwiftUIMomentsRowWidgetView(viewModel: viewModel.momentsTabsViewModel)
                    .frame(height: 300)
            }
            .padding(.top)
        }
        .navigationTitle("Follow Entities")
        .customBackButton()
        .onAppear { viewModel.viewDidAppear() }
        .onDisappear { viewModel.viewWillDisappear() }
    }
}

#Preview {
    FollowEntitiesSwiftUIView()
}
