//
//  VideoPlayerExamples.swift
//  BlazeSDK
//
//  Created by Niko Pich on 10/08/25.
//  Copyright © 2025 com.WSCSports. All rights reserved.
//

import SwiftUI
import BlazeSDK

/// Collection of examples demonstrating how to use BlazeSDK SwiftUI video components.
/// These examples showcase different integration patterns and use cases.
@available(iOS 14.0, *)
internal struct VideoPlayerExamples {

    // MARK: - Simple Feed Example
    
    /// Example showing how to create a simple video feed with automatic playback.
    internal struct SimpleFeedExample: View {
        private let videoLabel = ConfigManager.videoInlineLabel
        
        internal init() {}
        
        internal var body: some View {
            GeometryReader { geometry in
                ScrollView {
                    LazyVStack(spacing: 60) {
                        ForEach(0..<5, id: \.self) { index in
                            BlazeInFeedVideoPlayerView.preview(
                                dataSourceType: .labels(.singleLabel(videoLabel)),
                                id: "\(videoLabel)-\(index)"
                            )
                            .aspectRatio(16/9, contentMode: .fit)
                            .background(Color.black)
                        }
                    }
                    .padding(.bottom, geometry.size.height / 2)
                    .padding(.top, 12)

                }
                .videoFeedAutoPlay(threshold: 0.6) { playingVideoId in
                    print("📺 [SimpleFeedExample] ═══════════════════════════════")
                    print("📺 [SimpleFeedExample] Currently playing ID changed to: \(playingVideoId ?? "none")")
                    print("📺 [SimpleFeedExample] ═══════════════════════════════")
                }
            }
            .navigationTitle("Simple Feed")
            .navigationBarTitleDisplayMode(.inline)
            .customBackButton()
        }
    }
}


// MARK: - PlayerControllerExample

extension VideoPlayerExamples {
    /// Example showing how to use the BlazeVideoPlayerController for programmatic control.
    internal struct PlayerControllerExample: View {
        @StateObject private var playerController = BlazeSwiftUIVideoInlinePlayerController()
        @State private var embeddedState: BlazeSwiftUIVideosInlinePlayerView.EmbeddedState = .placeholder
        
        internal init() {}
        
        internal var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Player Controls")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Use the BlazeSwiftUIVideoInlinePlayerController to programmatically control the player")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    BlazeSwiftUIVideosInlinePlayerView(
                        configuration: BlazeSwiftUIVideosInlinePlayerView.Configuration(
                            playerMode: .interactive(interactivePlyerStyle: .base()),
                            dataSourceType: .labels(.singleLabel(ConfigManager.videoInlineLabel)),
                            containerIdentifier: ConfigManager.videoInlineLabel,
                            shouldOrderVideosByReadStatus: true,
                            cachePolicyLevel: nil,
                            adsConfigType: .firstAvailableAdsConfig
                        ),
                        playerController: playerController,
                        embeddedState: embeddedState
                    )
                    .aspectRatio(16/9, contentMode: .fit)
                    .background(Color.black)
                    
                    // State Control
                    HStack(spacing: 12) {
                        Button(action: {
                            embeddedState = .placeholder
                        }) {
                            Text("Placeholder")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(6)
                        }
                        
                        Button(action: {
                            embeddedState = .player(autoPlayOnStart: false)
                        }) {
                            Text("Embed")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                        
                        Button(action: {
                            embeddedState = .player(autoPlayOnStart: true)
                        }) {
                            Text("Auto-Play")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                    }
                    
                    // Player Control
                    VStack(spacing: 12) {
                        Text("Player Controls")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                playerController.resumePlayer()
                            }) {
                                Label("Resume", systemImage: "play.fill")
                                    .frame(height: 44)
                                    .padding(.horizontal)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                playerController.pausePlayer()
                            }) {
                                Label("Pause", systemImage: "pause.fill")
                                    .frame(height: 44)
                                    .padding(.horizontal)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                playerController.enterFullScreen()
                            }) {
                                Text("Full Screen")
                                    .frame(height: 44)
                                    .padding(.horizontal)
                                    .background(Color.purple)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                playerController.blockInteraction()
                            }) {
                                Text("Block Interaction")
                                    .frame(height: 44)
                                    .padding(.horizontal)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                playerController.unblockInteraction()
                            }) {
                                Text("Unblock Interaction")
                                    .frame(height: 44)
                                    .padding(.horizontal)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Spacer()
                }
            }
            .navigationTitle("Player Controls")
            .navigationBarTitleDisplayMode(.inline)
            .customBackButton()
        }
    }
}
