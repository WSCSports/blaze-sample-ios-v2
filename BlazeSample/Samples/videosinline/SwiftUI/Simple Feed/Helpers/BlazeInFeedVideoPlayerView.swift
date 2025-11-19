//
//  BlazeInFeedVideoPlayerView.swift
//  BlazeSDK
//
//  Created by Niko Pich on 10/08/25.
//  Copyright © 2025 com.WSCSports. All rights reserved.
//

import SwiftUI
import UIKit
import Combine
import BlazeSDK



// MARK: - BlazeInFeedVideoPlayerView

/**
 `BlazeInFeedVideoPlayerView` is a specialized SwiftUI view optimized for video feed scenarios that automatically manages player state based on scroll position and visibility.
 
 This view is designed specifically for use in scrollable feeds where multiple video players might be present simultaneously. It automatically switches between placeholder images and active video players based on scroll behavior, optimizing performance and user experience by only playing videos when they are prominently visible.
 
 The view integrates with a `VideoFeedScrollStateManager` environment object to coordinate scroll-based player management across multiple instances in a feed, ensuring only one video plays at a time and reducing resource consumption.
 
 - Important: This view requires a `VideoFeedScrollStateManager` to be provided as an environment object to function properly. Without this dependency, the view will not be able to coordinate with other feed players.
 
 ### Usage Example
 ```swift
 ScrollView {
 LazyVStack {
 ForEach(videoItems) { item in
 BlazeInFeedVideoPlayerView(
 playerMode: .preview(previewPlayerStyle: .base()),
 dataSourceType: .labels(.singleLabel(item.label)),
 containerIdentifier: item.id
 )
 .inlinePlayerDelegate(feedDelegate)
 }
 }
 }
 .environmentObject(VideoFeedScrollStateManager())
 ```
 
 - Note: The view automatically handles the transition between placeholder and player states based on scroll position, eliminating the need for manual state management in feed scenarios.
 
 - SeeAlso: ``BlazeSwiftUIVideosInlinePlayerView``, ``VideoFeedScrollStateManager``
 */
@available(iOS 14.0, *)
internal struct BlazeInFeedVideoPlayerView: View {
    
    // MARK: - Configuration
    
    /// The visual and behavioral style of the player container, optimized for feed scenarios.
    private let playerMode: BlazeVideosInlinePlayer.PlayerMode
    
    /// The data source configuration that defines how video content is retrieved for this feed item.
    private let dataSourceType: BlazeDataSourceType
    
    /// Unique identifier for this player instance within the feed context.
    private let containerIdentifier: String
    
    /// Cache policy configuration for optimizing video content loading in feed scenarios.
    private let cachePolicyLevel: BlazeCachePolicyLevel?
    
    /// Advertisement configuration type for feed-optimized ad integration.
    private let adsConfigType: BlazeVideosAdsConfigType
    
    // MARK: - State
    
    /// The current embedded state, automatically managed based on scroll position and visibility.
    //    @State private var embeddedState: BlazeSwiftUIVideosInlinePlayerView.EmbeddedState = .placeholder
    
    /// Environment object that coordinates scroll-based player management across feed instances.
    @EnvironmentObject private var scrollManager: VideoFeedScrollStateManager
    
    
    // MARK: - Event Handlers
    
    /// Optional delegate for handling player events specific to this feed item.
    private var inlinePlayerDelegate: BlazeInlinePlayerDelegate?
    
    /// Controller providing programmatic access to player operations for this feed item.
    private var playerController: BlazeSwiftUIVideoInlinePlayerController
    
    // MARK: - Initializer
    
    /**
     Creates a new feed-optimized video player view with automatic scroll-based state management.
     
     - Parameters:
     - playerMode: The visual and behavioral style of the player container. Typically `.preview` mode is recommended for feed scenarios to provide optimal performance with automatic full-screen transitions.
     - dataSourceType: The data source configuration that defines how video content is retrieved. Common patterns include label-based or playlist-based sources.
     - containerIdentifier: Unique identifier for this player instance within the feed. Must be unique among all feed items to ensure proper scroll coordination and analytics tracking.
     - inlinePlayerDelegate: Optional delegate for handling player events specific to this feed item. Receives callbacks for player interactions and state changes.
     - cachePolicyLevel: Cache policy configuration for optimizing video loading in feed scenarios. Use `nil` for default caching behavior optimized for feeds.
     - playerController: Optional controller for programmatic player control. If not provided, a default controller will be created automatically.
     - adsConfigType: Advertisement configuration optimized for feed scenarios. Defaults to the primary ad configuration.
     
     - Important: Ensure the `containerIdentifier` is unique within your feed to prevent conflicts in scroll coordination and analytics tracking.
     
     ### Usage Example
     ```swift
     ForEach(feedItems) { item in
     BlazeInFeedVideoPlayerView(
     playerMode: .preview(previewPlayerStyle: .base()),
     dataSourceType: .labels(.singleLabel(item.videoLabel)),
     containerIdentifier: "feed-\(item.id)",
     inlinePlayerDelegate: feedDelegate
     )
     }
     ```
     */
    public init(
        playerMode: BlazeVideosInlinePlayer.PlayerMode,
        dataSourceType: BlazeDataSourceType,
        containerIdentifier: String,
        inlinePlayerDelegate: BlazeInlinePlayerDelegate? = nil,
        cachePolicyLevel: BlazeCachePolicyLevel? = nil,
        playerController: BlazeSwiftUIVideoInlinePlayerController? = nil,
        adsConfigType: BlazeVideosAdsConfigType = .firstAvailableAdsConfig
    ) {
        self.playerMode = playerMode
        self.dataSourceType = dataSourceType
        self.containerIdentifier = containerIdentifier
        self.inlinePlayerDelegate = inlinePlayerDelegate
        self.cachePolicyLevel = cachePolicyLevel
        self.playerController = playerController ?? .init()
        self.adsConfigType = adsConfigType
    }
    
    // MARK: - Body
    
    public var body: some View {
        let _ = Self._printChanges()
        inlinePlayerView()
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: PlayerCellPositionPreferenceKey.self,
                            value: [PlayerCellPositionPreferenceKey.CellPosition(
                                id: containerIdentifier,
                                frame: geometry.frame(in: .global)
                            )]
                        )
                }
            )
    }
    
    // MARK: - Private Methods
    
    @ViewBuilder
    private func inlinePlayerView() -> some View {
        let newState: BlazeSwiftUIVideosInlinePlayerView.EmbeddedState = scrollManager.currentlyPlayingId == containerIdentifier ? .player(autoPlayOnStart: true) : .placeholder
        BlazeSwiftUIVideosInlinePlayerView(
            configuration: .init(
                playerMode: playerMode,
                dataSourceType: dataSourceType,
                containerIdentifier: containerIdentifier
            ),
            playerController: playerController,
            embeddedState: newState
        )
        .inlinePlayerDelegate(inlinePlayerDelegate ?? BlazeInlinePlayerDelegate())
    }
}

// MARK: - Convenience Extensions

@available(iOS 14.0, *)
internal extension BlazeInFeedVideoPlayerView {
    
    /**
     Creates a preview-mode player optimized for feed scenarios with automatic full-screen transitions.
     
     Preview mode is ideal for feed scenarios as it displays minimal overlay UI and automatically transitions to full-screen when the user taps on the player area. This provides a clean feed appearance while maintaining full video functionality.
     
     - Parameters:
     - dataSourceType: The data source configuration for video content retrieval.
     - id: Unique identifier for this feed item, used for scroll coordination and analytics.
     - previewStyle: Visual styling configuration for the preview player overlay. Defaults to base styling.
     - fullScreenStyle: Optional styling configuration for the full-screen player. Uses default styling if not provided.
     - inlinePlayerDelegate: Optional delegate for handling player events and interactions.
     
     - Returns: A configured feed player view in preview mode with automatic scroll management.
     
     ### Usage Example
     ```swift
     ForEach(feedItems) { item in
     BlazeInFeedVideoPlayerView.preview(
     dataSourceType: .labels(.singleLabel(item.label)),
     id: "feed-\(item.id)",
     inlinePlayerDelegate: feedDelegate
     )
     }
     ```
     
     - SeeAlso: `interactive(dataSourceType:id:interactiveStyle:fullScreenStyle:inlinePlayerDelegate:)`
     */
    static func preview(
        dataSourceType: BlazeDataSourceType,
        id: String,
        previewStyle: BlazeVideosInlinePreviewPlayerStyle = .base(),
        fullScreenStyle: BlazeVideosPlayerStyle? = nil,
        inlinePlayerDelegate: BlazeInlinePlayerDelegate? = nil
    ) -> BlazeInFeedVideoPlayerView {
        BlazeInFeedVideoPlayerView(
            playerMode: .preview(
                previewPlayerStyle: previewStyle,
                fullScreenPlayerStyle: fullScreenStyle
            ),
            dataSourceType: dataSourceType,
            containerIdentifier: id,
            inlinePlayerDelegate: inlinePlayerDelegate
        )
    }
    
    /**
     Creates an interactive-mode player for feed scenarios with full inline controls.
     
     Interactive mode provides complete playback controls directly within the feed item, allowing users to play, pause, seek, and control the video without transitioning to full-screen. This mode is suitable when you want to provide rich inline video experiences within your feed.
     
     - Parameters:
     - dataSourceType: The data source configuration for video content retrieval.
     - id: Unique identifier for this feed item, used for scroll coordination and analytics.
     - interactiveStyle: Visual styling configuration for the interactive player overlay. Defaults to base styling with full controls.
     - fullScreenStyle: Optional styling configuration for the full-screen player. Uses default styling if not provided.
     - inlinePlayerDelegate: Optional delegate for handling player events and interactions.
     
     - Returns: A configured feed player view in interactive mode with automatic scroll management.
     
     - Important: Interactive mode players consume more resources than preview mode. Consider using preview mode for better performance in feeds with many video items.
     
     ### Usage Example
     ```swift
     // Use for featured content that should play inline
     BlazeInFeedVideoPlayerView.interactive(
     dataSourceType: .playlist(playlistId: "featured"),
     id: "hero-video",
     inlinePlayerDelegate: featuredDelegate
     )
     ```
     
     - SeeAlso: `preview(dataSourceType:id:previewStyle:fullScreenStyle:inlinePlayerDelegate:)`
     */
    static func interactive(
        dataSourceType: BlazeDataSourceType,
        id: String,
        interactiveStyle: BlazeVideosInlineInteractivePlayerStyle = .base(),
        fullScreenStyle: BlazeVideosPlayerStyle? = nil,
        inlinePlayerDelegate: BlazeInlinePlayerDelegate? = nil
    ) -> BlazeInFeedVideoPlayerView {
        BlazeInFeedVideoPlayerView(
            playerMode: .interactive(
                interactivePlyerStyle: interactiveStyle,
                fullScreenPlayerStyle: fullScreenStyle
            ),
            dataSourceType: dataSourceType,
            containerIdentifier: id,
            inlinePlayerDelegate: inlinePlayerDelegate
        )
    }
}
