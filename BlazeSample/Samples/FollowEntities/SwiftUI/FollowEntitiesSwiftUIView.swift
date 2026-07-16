//
//  FollowEntitiesSwiftUIView.swift
//  blaze-sample-ios-v2
//

import SwiftUI
import BlazeSDK

///
/// `FollowEntitiesSwiftUIView` demonstrates the BlazeSDK Follow Entities feature end to end,
/// via a single tabs-backed Moments widget (Trending / For You / Your Picks), built with SwiftUI.
/// "Your Picks" is personalized from the entities the user follows in the moments player
/// (see `Samples/FollowEntities/Follow/`). Mirrors `FollowEntitiesViewController`, the UIKit variant.
///
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
