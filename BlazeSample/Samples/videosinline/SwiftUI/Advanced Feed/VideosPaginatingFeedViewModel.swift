//
//  VideosPaginatingFeedViewModel.swift
//  BlazePrime
//
//  Created by Niko Pich on 10/08/25.
//  Copyright © 2025 com.WSCSports. All rights reserved.
//

import SwiftUI
import BlazeSDK
import Combine


@available(iOS 14.0, *)
@MainActor
internal class VideosPaginatingFeedViewModel: ObservableObject {
    
    internal enum FeedItem: Identifiable {
        case inlinePreview(InlineFeedItem)
        case inlineInteractive(InlineFeedItem)
        
        internal var id: String {
            switch self {
            case .inlinePreview(let item):
                item.id
            case .inlineInteractive(let item):
                item.id
            }
        }
    }
    
    internal struct InlineFeedItem: Identifiable, Equatable {
        internal let id: String
        internal let title: String
        internal let playerMode: BlazeVideosInlinePlayer.PlayerMode
        internal let dataSourceType: BlazeDataSourceType
        internal let inlinePlayerDelegate: BlazeInlinePlayerDelegate
        internal let playerController: BlazeSwiftUIVideoInlinePlayerController
        
        internal static func == (lhs: VideosPaginatingFeedViewModel.InlineFeedItem, rhs: VideosPaginatingFeedViewModel.InlineFeedItem) -> Bool {
            lhs.id == rhs.id && lhs.title == rhs.title && lhs.playerMode == rhs.playerMode && lhs.dataSourceType == rhs.dataSourceType
        }
    }
    
    @Published internal var feedItems: [FeedItem] = []
    @Published internal var currentlyPlayingItemId: String?
    
    private(set) var isFullScreenPlayerPresented: Bool = false
    
    @Published internal var isLoadingMoreItems: Bool = false
    private var currentPage: Int = 1
    internal let itemsPerPage: Int = 10
    private let paginationThreshold: CGFloat = 0 // Trigger pagination when 0pt from bottom
    
    // MARK: - Scroll Performance Management
    private var updateWorkItem: DispatchWorkItem?
    private var pendingPositions: [PlayerCellPositionPreferenceKey.CellPosition] = []
    private var scrollViewFrame: CGRect = .zero
    
    // MARK: - Configuration
    /// Visibility threshold for video playback (0.0 to 1.0)
    /// Default: 0.7 (70% visibility required) - matches VideoFeedScrollStateManager default
    private let visibilityThreshold: CGFloat
    
    private let videoLabel: String = ConfigManager.videoInlineLabel
    
    internal init(visibilityThreshold: CGFloat = 0.7) {
        self.visibilityThreshold = visibilityThreshold
        setupFeedItems()
    }
    
    deinit {
        updateWorkItem?.cancel()
    }
    
    private func setupFeedItems() {
        feedItems = createFeedItemsForPage(1)
    }
    
    /// Creates [itemsPerPage] feed items for a specific page using the video long form label
    private func createFeedItemsForPage(_ page: Int) -> [FeedItem] {
        return (0..<itemsPerPage).map { index in
            let uniqueIdentifier = "\(videoLabel)-page\(page)-item\(index)"
            
            return .inlinePreview(
                .init(
                    id: uniqueIdentifier,
                    title: "\(videoLabel) (Video #\(index + 1), Page #\(page))",
                    playerMode: .preview(previewPlayerStyle: .base()),
                    dataSourceType: .labels(.singleLabel(videoLabel)),
                    inlinePlayerDelegate: createContainerDelegate(for: uniqueIdentifier),
                    playerController: BlazeSwiftUIVideoInlinePlayerController()
                )
            )
        }
    }
    
    /// Loads the next page of items if not already loading
    internal func loadMoreItemsIfNeeded() async {
        guard !isLoadingMoreItems else { return }
        
        isLoadingMoreItems = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 900_000_000)
        
        currentPage += 1
        let newItems = createFeedItemsForPage(currentPage)
        feedItems.append(contentsOf: newItems)
        isLoadingMoreItems = false
    }
    
    // MARK: - Playback Management (reproduced from original)
    
    internal func shouldEmbedPlayer(for itemId: String) -> Bool {
        let shouldEmbed = currentlyPlayingItemId == itemId
        return shouldEmbed
    }
    
    internal func updatePlaybackState(for itemId: String?) async {
        print("📺 [VideosFeedViewModel] ═══════════════════════════════")
        print("📺 [VideosFeedViewModel] updatePlaybackState called")
        print("📺 [VideosFeedViewModel] Previous ID: \(currentlyPlayingItemId ?? "nil")")
        print("📺 [VideosFeedViewModel] New ID: \(itemId ?? "nil")")
        
        guard currentlyPlayingItemId != itemId else {
            print("📺 [VideosFeedViewModel] ⚠️ Same ID - Skipping update")
            print("📺 [VideosFeedViewModel] ═══════════════════════════════")
            return
        }
        
        // Update to new playing item
        currentlyPlayingItemId = itemId
        print("📺 [VideosFeedViewModel] ✅ Updated currentlyPlayingItemId to: \(itemId ?? "nil")")
        print("📺 [VideosFeedViewModel] ═══════════════════════════════")
    }
    
    // MARK: - Scroll Performance Management (reproduced from original)
    
    /// Updates the scroll view frame for position calculations
    internal func updateScrollViewFrame(_ frame: CGRect) async {
        scrollViewFrame = frame
    }
    
    /// Handles position preference changes with debounced updates
    internal func handlePositionPreferenceChange(_ positions: [PlayerCellPositionPreferenceKey.CellPosition], isScrolling: Bool) async {
        pendingPositions = positions
        
        // Check for pagination immediately during scrolling, don't wait for scroll to end
        await checkForPaginationTrigger(positions)
        
        // Schedule video playback update (this still waits for scroll to end)
        await scheduleVideoPlaybackUpdate(isScrolling: isScrolling)
    }
    
    /// Handles scroll gesture changes - cancels pending updates when scrolling starts
    internal func handleScrollGestureChanged() async {
        updateWorkItem?.cancel()
    }
    
    /// Handles scroll gesture end - schedules debounced update
    internal func handleScrollGestureEnded() async {
        await scheduleVideoPlaybackUpdate(isScrolling: false)
    }
    
    /// Checks if pagination should be triggered immediately during scrolling
    private func checkForPaginationTrigger(_ positions: [PlayerCellPositionPreferenceKey.CellPosition]) async {
        guard !positions.isEmpty, !isLoadingMoreItems else { return }
        
        // Get the scroll view's visible frame
        let visibleHeight = scrollViewFrame.height
        guard visibleHeight > 0 else { return }
        
        // Calculate how close we are to the bottom of all content
        let maxY = positions.map { $0.frame.maxY }.max() ?? 0
        let scrollViewMaxY = scrollViewFrame.maxY
        let distanceFromBottom = maxY - scrollViewMaxY
        let shouldTriggerPagination = distanceFromBottom <= paginationThreshold && maxY > 0
        
        if shouldTriggerPagination {
            await loadMoreItemsIfNeeded()
        }
    }
    
    /// Schedules a debounced video playback update, similar to UIScrollView delegate behavior
    /// This prevents frequent updates during scrolling, improving performance
    private func scheduleVideoPlaybackUpdate(isScrolling: Bool) async {
        // Cancel any existing pending update
        updateWorkItem?.cancel()
        
        // Create new work item for debounced execution using Task for proper MainActor isolation
        let workItem = DispatchWorkItem {
            Task { @MainActor [weak self] in
                // Only execute if scrolling has stopped
                guard !isScrolling else { return }
                await self?.updateVideoPlayback()
            }
        }
        updateWorkItem = workItem
        
        // Defer updateVideoPlayback execution
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: workItem)
    }
    
    /// Updates video playback based on cell positions, only called when scrolling settles
    /// This mimics UIScrollView's scrollViewDidEndDragging/scrollViewDidEndDecelerating behavior
    private func updateVideoPlayback() async {
        print("📺 [VideosFeedViewModel] 🔍 updateVideoPlayback called")
        
        let positions = pendingPositions
        guard !positions.isEmpty else {
            print("📺 [VideosFeedViewModel] ⚠️ No positions - returning early")
            return
        }
        
        print("📺 [VideosFeedViewModel] 📊 Processing \(positions.count) positions")
        
        // Get the scroll view's visible frame
        let visibleHeight = scrollViewFrame.height
        guard visibleHeight > 0 else {
            print("📺 [VideosFeedViewModel] ⚠️ Invalid scroll frame height: \(visibleHeight) - returning early")
            return
        }
        
        print("📺 [VideosFeedViewModel] 📐 ScrollView frame: \(scrollViewFrame)")
        print("📺 [VideosFeedViewModel] 📐 Visible height: \(visibleHeight)")
        
        // Define top half area (invisible rectangle)
        let topHalf = CGRect(
            x: scrollViewFrame.minX,
            y: scrollViewFrame.minY,
            width: scrollViewFrame.width,
            height: visibleHeight / 2
        )
        
        // Track cell candidates
        var bestCell: (id: String, ratio: CGFloat)?
        var fallbackCell: (id: String, topVisibleHeight: CGFloat)?
        var lastVisibleCell: (id: String, position: Int)?
        
        // Check if we're near bottom (for video playback logic)
        let maxY = positions.map { $0.frame.maxY }.max() ?? 0
        let scrollViewMaxY = scrollViewFrame.maxY
        let isNearBottom = maxY > 0 && (scrollViewMaxY > maxY - visibleHeight/2)
        
        for (index, cellPosition) in positions.enumerated() {
            let cellFrame = cellPosition.frame
            
            // Skip cells that are not visible at all
            guard cellFrame.intersects(scrollViewFrame) else { continue }
            
            // Calculate intersection with top half
            let intersection = cellFrame.intersection(topHalf)
            let topVisibleHeight = intersection.height
            
            // Track last visible cell (highest index)
            if cellFrame.intersects(scrollViewFrame) {
                if lastVisibleCell == nil || index > lastVisibleCell!.position {
                    lastVisibleCell = (cellPosition.id, index)
                }
            }
            
            if topVisibleHeight > 0 {
                // Calculate ratio of cell in top half
                let ratio = topVisibleHeight / cellFrame.height
                
                // First priority: cell with visibility above threshold in top half
                if ratio > visibilityThreshold && (bestCell == nil || ratio > bestCell!.ratio) {
                    bestCell = (cellPosition.id, ratio)
                }
                
                // Fallback: cell with most visibility in top half
                if fallbackCell == nil || topVisibleHeight > fallbackCell!.topVisibleHeight {
                    fallbackCell = (cellPosition.id, topVisibleHeight)
                }
            }
        }
        
        // Choose cell to play (matching UIKit logic)
        var cellIdToPlay: String?
        
        if let best = bestCell {
            print("📺 [VideosFeedViewModel] ✅ Best candidate selected: \(best.id) (ratio: \(best.ratio))")
            cellIdToPlay = best.id
        } else if let fallback = fallbackCell {
            print("📺 [VideosFeedViewModel] ⚠️ Fallback candidate selected: \(fallback.id) (topVisibleHeight: \(fallback.topVisibleHeight))")
            cellIdToPlay = fallback.id
        } else if isNearBottom, let lastCell = lastVisibleCell {
            // When near bottom with no good candidate, prioritize the last visible cell
            print("📺 [VideosFeedViewModel] 🔽 Near bottom - last visible selected: \(lastCell.id)")
            cellIdToPlay = lastCell.id
        } else {
            print("📺 [VideosFeedViewModel] ❌ No candidate found")
        }
        
        print("📺 [VideosFeedViewModel] 🎯 Final decision: cellIdToPlay = \(cellIdToPlay ?? "nil")")
        
        // Update playback state
        await updatePlaybackState(for: cellIdToPlay)
    }
    
    private func createContainerDelegate(for itemId: String) -> BlazeInlinePlayerDelegate {
        BlazeInlinePlayerDelegate(
            onPlayerDidEnterFullScreen: { args in
                print("Video \(itemId) entered full screen")
            },
            onPlayerDidExitFullScreen: { args in
                print("Video \(itemId) exited full screen")
            },
            onPlaceholderClicked: { args in
                print("Video \(itemId) placeholder clicked")
            }
        )
    }
}
