//
//  VideoFeedCell.swift
//  BlazePrime
//
//  Created by Niko Pich on 10/08/25.
//  Copyright © 2025 com.WSCSports. All rights reserved.
//

import SwiftUI
import BlazeSDK

// MARK: - Video Feed Cell (@StateObject Implementation)

/// This cell demonstrates **Approach #2**: Controller stored in model (outlives view).
/// The controller is managed by the model, allowing it to outlive the view for better performance in feeds.
/// Features a QA-friendly overlay that appears only in player mode with controller action buttons.
@available(iOS 14.0, *)
internal struct VideoFeedCell: View {
    internal let feedItem: VideosPaginatingFeedViewModel.InlineFeedItem
    internal let embeddedState: BlazeSwiftUIVideosInlinePlayerView.EmbeddedState
    private var player: BlazeSwiftUIVideoInlinePlayerController { feedItem.playerController }
    
    // Approach #2: Controller comes from model - can outlive the view
    
    internal init(feedItem: VideosPaginatingFeedViewModel.InlineFeedItem, embeddedState: BlazeSwiftUIVideosInlinePlayerView.EmbeddedState) {
        self.feedItem = feedItem
        self.embeddedState = embeddedState
    }
    
    internal var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Image(.flagUs)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                
                Text(feedItem.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(8)
            .background(Color.white)
            
            // Player - using BlazeVideoPlayerView with controller from the passed model (Approach #2)
            BlazeSwiftUIVideosInlinePlayerView(
                configuration: .init(
                    playerMode: feedItem.playerMode,
                    dataSourceType: feedItem.dataSourceType,
                    containerIdentifier: feedItem.id
                ),
                playerController: player,
                embeddedState: embeddedState
            )
            .inlinePlayerDelegate(feedItem.inlinePlayerDelegate)
            .aspectRatio(16.0/9.0, contentMode: .fit)
            .background(Color.black)
            // Note: You can add a custom overlay using `BlazeSwiftUIVideoInlinePlayerController`.
//            .overlay(
//                playerModeOverlay
//                    .animation(.bouncy, value: embeddedState)
//            )
        }
        .background(Color.clear)
    }
    
    @ViewBuilder
    private var playerModeOverlay: some View {
        if case .player = embeddedState, case .preview = feedItem.playerMode {
            VStack {
                HStack {
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Button("⏸️") {
                            player.pausePlayer()
                        }
                        .font(.caption.bold())
                        .foregroundColor(.black)
                        .frame(width: 32, height: 32)
                        .background(Color(.wscAccent).opacity(0.5))
                        .clipShape(Circle())
                        
                        Button("▶️") {
                            player.resumePlayer()
                        }
                        .font(.caption.bold())
                        .foregroundColor(.black)
                        .frame(width: 32, height: 32)
                        .background(Color(.wscAccent).opacity(0.5))
                        .clipShape(Circle())
                        
                        Button("⛶") {
                            player.enterFullScreen()
                        }
                        .font(.caption.bold())
                        .foregroundColor(.black)
                        .frame(width: 32, height: 32)
                        .background(Color(.wscAccent).opacity(0.5))
                        .clipShape(Circle())
                    }
                    .padding(.top, 8)
                    .padding(.trailing, 8)
                }
                
                Spacer()
                
                HStack {
                    Text("Playing...")
                        .font(.caption.bold())
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.wscAccent).opacity(0.5))
                                .blur(radius: 0.5)
                        )
                    
                    Spacer()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
                
            }
        }
    }
}
