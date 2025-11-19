//
//  VideoFeedScrollStateManager.swift
//  BlazeSDK
//
//  Created by Niko Pich on 10/08/25.
//  Copyright © 2025 com.WSCSports. All rights reserved.
//

import SwiftUI
import Combine
import Foundation



// MARK: - Video Position Tracking



// MARK: - Scroll State Manager

/// Manages scroll-based video playback behavior for feed scenarios
@available(iOS 14.0, *)
@MainActor
internal class VideoFeedScrollStateManager: ObservableObject {
    
    // MARK: - Configuration
    
    struct Configuration {
        let visibilityThreshold: CGFloat
        let scrollEndDetectionDelay: TimeInterval
        let paginationThreshold: CGFloat
        
        static let `default` = Configuration(
            visibilityThreshold: 0.7,
            scrollEndDetectionDelay: 0.15,
            paginationThreshold: 50.0
        )
    }
    
    // MARK: - Published State
    
    @Published private(set) var currentlyPlayingId: String?
    
    // MARK: - Private Properties
    
    private let configuration: Configuration
    private var scrollViewFrame: CGRect = .zero
    private var pendingPositions: [PlayerCellPositionPreferenceKey.CellPosition] = []
    private var updateWorkItem: DispatchWorkItem?
    
    // Track initial view appearance to prevent premature updates during geometry settling
    private var isInitialAppearance: Bool = true
    
    // MARK: - Callbacks
    
    var onPlaybackStateChange: ((String?) -> Void)?
    
    // MARK: - Initialization
    
    init(configuration: Configuration = .default) {
        self.configuration = configuration
    }
    
    deinit {
        updateWorkItem?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Updates the scroll view frame for position calculations
    func updateScrollViewFrame(_ frame: CGRect) {
        scrollViewFrame = frame
    }
    
    /// Handles position preference changes with debounced updates
    func handlePositionPreferenceChange(_ positions: [PlayerCellPositionPreferenceKey.CellPosition], isScrolling: Bool) async {
        pendingPositions = positions
        
        // Schedule video playback update (this still waits for scroll to end)
        await scheduleVideoPlaybackUpdate(isScrolling: isScrolling)
    }
    
    /// Handles scroll gesture changes - cancels pending updates when scrolling starts
    func handleScrollGestureChanged() async {
        updateWorkItem?.cancel()
    }
    
    /// Handles scroll gesture end - schedules debounced update
    func handleScrollGestureEnded() async {
        await scheduleVideoPlaybackUpdate(isScrolling: false)
    }
    
    
    // MARK: - Private Methods
    
    /// Schedules a debounced video playback update, similar to UIScrollView delegate behavior
    /// This prevents frequent updates during scrolling, improving performance
    private func scheduleVideoPlaybackUpdate(isScrolling: Bool) async {
        // Cancel any existing pending update
        updateWorkItem?.cancel()
        
        // Determine delay based on whether this is initial appearance
        // During initial appearance, use longer delay to let geometries stabilize
        let delay: TimeInterval = isInitialAppearance ? 0.6 : 0.2
        
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
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
    
    /// Updates video playback based on cell positions, only called when scrolling settles
    /// This mimics UIScrollView's scrollViewDidEndDragging/scrollViewDidEndDecelerating behavior
    private func updateVideoPlayback() async {
        let positions = pendingPositions
        guard !positions.isEmpty else { return }
        
        // Get the scroll view's visible frame
        let visibleHeight = scrollViewFrame.height
        guard visibleHeight > 0 else { return }
        
        // Define top half area for video playback detection
        let topHalf = CGRect(
            x: scrollViewFrame.minX,
            y: scrollViewFrame.minY,
            width: scrollViewFrame.width,
            height: visibleHeight / 2
        )
        
        // Find the best candidate for video playback
        let playerId = findBestPlayerCandidate(positions: positions, topHalf: topHalf)
        
        // Update playback state if changed
        if currentlyPlayingId != playerId {
            currentlyPlayingId = playerId
            onPlaybackStateChange?(playerId)
        }
        
        // After first update completes (regardless of whether ID changed), exit initial appearance mode
        // This ensures subsequent scrolling uses the faster 0.2s delay
        if isInitialAppearance {
            isInitialAppearance = false
        }
    }
    
    /// Finds the best player candidate based on visibility rules
    private func findBestPlayerCandidate(
        positions: [PlayerCellPositionPreferenceKey.CellPosition],
        topHalf: CGRect
    ) -> String? {
        // Track candidates
        var bestCandidate: (id: String, ratio: CGFloat)?
        var fallbackCandidate: (id: String, topVisibleHeight: CGFloat)?
        var lastVisibleCandidate: (id: String, position: Int)?
        
        // Check if we're near bottom
        let maxY = positions.map { $0.frame.maxY }.max() ?? 0
        let scrollViewMaxY = scrollViewFrame.maxY
        let isNearBottom = maxY > 0 && (scrollViewMaxY > maxY - scrollViewFrame.height / 2)
        
        for (index, playerPosition) in positions.enumerated() {
            let playerFrame = playerPosition.frame
            
            // Skip players that are not visible at all
            guard playerFrame.intersects(scrollViewFrame) else { continue }
            
            // Calculate intersection with top half
            let intersection = playerFrame.intersection(topHalf)
            let topVisibleHeight = intersection.height
            
            // Track last visible player (highest index)
            if playerFrame.intersects(scrollViewFrame) {
                if lastVisibleCandidate == nil || index > lastVisibleCandidate!.position {
                    lastVisibleCandidate = (playerPosition.id, index)
                }
            }
            
            if topVisibleHeight > 0 {
                // Calculate visibility ratio in top half
                let ratio = topVisibleHeight / playerFrame.height
                
                // First priority: player with >threshold visibility in top half
                if ratio > configuration.visibilityThreshold && (bestCandidate == nil || ratio > bestCandidate!.ratio) {
                    bestCandidate = (playerPosition.id, ratio)
                }
                
                // Fallback: player with most visibility in top half
                if fallbackCandidate == nil || topVisibleHeight > fallbackCandidate!.topVisibleHeight {
                    fallbackCandidate = (playerPosition.id, topVisibleHeight)
                }
            }
        }
        
        // Choose player based on priority rules
        if let best = bestCandidate {
            return best.id
        } else if let fallback = fallbackCandidate {
            return fallback.id
        } else if isNearBottom, let lastVisible = lastVisibleCandidate {
            return lastVisible.id
        }
        
        return nil
    }
}

// MARK: - View Modifiers

@available(iOS 14.0, *)
extension View {
    
    /// Adds automatic video feed playback behavior to a scroll view containing video players.
    ///
    /// This modifier automatically manages video playback based on scroll position and visibility.
    /// Videos will play when they meet the visibility threshold in the top half of the scroll view.
    ///
    /// - Parameters:
    ///   - threshold: Visibility threshold (0.0 to 1.0) required for a video to start playing
    ///   - onPlaybackChange: Optional callback when playback state changes
    /// - Returns: A view with automatic video feed playback behavior
    func videoFeedAutoPlay(
        threshold: CGFloat = 0.7,
        onPlaybackChange: ((String?) -> Void)? = nil
    ) -> some View {
        VideoFeedAutoPlayModifier(
            threshold: threshold,
            onPlaybackChange: onPlaybackChange,
            content: self
        )
    }
}

// MARK: - Auto Play Modifier Implementation

@available(iOS 14.0, *)
private struct VideoFeedAutoPlayModifier<Content: View>: View {
    let threshold: CGFloat
    let onPlaybackChange: ((String?) -> Void)?
    let content: Content
    
    @StateObject private var scrollManager: VideoFeedScrollStateManager
    @State private var isScrolling: Bool = false
    @State private var scrollDetectionTimer: Timer?
    
    init(threshold: CGFloat, onPlaybackChange: ((String?) -> Void)?, content: Content) {
        self.threshold = threshold
        self.onPlaybackChange = onPlaybackChange
        self.content = content
        
        // Create configuration with custom threshold
        let configuration = VideoFeedScrollStateManager.Configuration(
            visibilityThreshold: threshold,
            scrollEndDetectionDelay: 0.15,
            paginationThreshold: 50.0
        )
        _scrollManager = StateObject(wrappedValue: VideoFeedScrollStateManager(configuration: configuration))
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            content
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .task {
                                scrollManager.updateScrollViewFrame(geometry.frame(in: .global))
                            }
                            .onChange(of: geometry.frame(in: .global)) { oldFrame in
                                scrollManager.updateScrollViewFrame( geometry.frame(in: .global))
                            }
                        
                    }
                )
        }
        .background(Color(UIColor.white))
        .onPreferenceChange(PlayerCellPositionPreferenceKey.self) { positions in
            // Detect scrolling through rapid position changes
            handleScrollDetection()
            
            // Delegate position handling to ScrollManager for debounced processing
            Task {
                await scrollManager.handlePositionPreferenceChange(positions, isScrolling: isScrolling)
            }
        }
        .onDisappear {
            scrollDetectionTimer?.invalidate()
            scrollDetectionTimer = nil
        }
        .environmentObject(scrollManager)
    }
    
    /// Detects scrolling through rapid preference changes without interfering with player interactions
    private func handleScrollDetection() {
        // Cancel existing timer
        scrollDetectionTimer?.invalidate()
        
        // Mark as scrolling if not already
        if !isScrolling {
            isScrolling = true
            Task {
                await scrollManager.handleScrollGestureChanged()
            }
        }
        
        // Set timer to detect when scrolling stops
        scrollDetectionTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { _ in
            // Scrolling has stopped (no preference changes for 150ms)
            self.isScrolling = false
            Task {
                await self.scrollManager.handleScrollGestureEnded()
            }
        }
    }
}
