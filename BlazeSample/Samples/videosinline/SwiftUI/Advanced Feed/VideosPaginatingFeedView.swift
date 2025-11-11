//
//  VideosPaginatingFeedView.swift
//  BlazePrime
//
//  Created by Niko Pich on 10/08/25.
//  Copyright © 2025 com.WSCSports. All rights reserved.
//

import SwiftUI
import BlazeSDK
import Combine


/// This demonstrates **Approach #2**: Controller stored in model (outlives view for better performance).
/// Each feed item contains its own controller that can outlive the view, preventing wasteful recreation 
/// when cells are scrolled in and out of view.
@available(iOS 14.0, *)
internal struct VideosPaginatingFeedView: View {
    @StateObject private var viewModel = VideosPaginatingFeedViewModel()
    
    @State private var isScrolling = false
    @State private var scrollDetectionTimer: Timer?
    
    // Grid layout
    private let columns: [GridItem] = [GridItem(.flexible(), spacing: 0)]
    
    internal init() {}
    
    internal var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    gridView
                        .padding(.bottom, geometry.size.height / 2)
                }
                .background(
                    GeometryReader { scrollGeometry in
                        Color.clear
                            .task {
                                await viewModel.updateScrollViewFrame(scrollGeometry.frame(in: .global))
                            }
                            .onChange(of: scrollGeometry.frame(in: .global)) { newFrame in
                                Task {
                                    await viewModel.updateScrollViewFrame(newFrame)
                                }
                            }
                    }
                )
            }
            .background(Color(UIColor.systemBackground))
            .onPreferenceChange(PlayerCellPositionPreferenceKey.self) { positions in
                // Detect scrolling through rapid position changes
                handleScrollDetection()
                
                // Delegate position handling to ViewModel for debounced processing
                Task {
                    await viewModel.handlePositionPreferenceChange(positions, isScrolling: isScrolling)
                }
            }
            .navigationTitle("Advanced Paginating Feed")
            .navigationBarTitleDisplayMode(.inline)
            .customBackButton()
            .onAppear {
                setupNavigationBarAppearance()
            }
            .onDisappear {
                // Clean up scroll detection timer
                scrollDetectionTimer?.invalidate()
                scrollDetectionTimer = nil
            }
        }
    }
    
    @ViewBuilder
    private var gridView: some View {
        LazyVGrid(columns: columns, spacing: 40) {
            ForEach(viewModel.feedItems, id: \.id) { feedItem in
                cellView(for: feedItem)
                    .background(
                        GeometryReader { cellGeometry in
                            Color.clear
                                .preference(
                                    key: PlayerCellPositionPreferenceKey.self,
                                    value: [PlayerCellPositionPreferenceKey.CellPosition(
                                        id: feedItem.id,
                                        frame: cellGeometry.frame(in: .global)
                                    )]
                                )
                        }
                    )
            }
            
            // Loading placeholders at the bottom
            if viewModel.isLoadingMoreItems {
                ForEach(0..<viewModel.itemsPerPage, id: \.self) { index in
                    loadingPlaceholderView(index: index)
                }
            }
        }
        .padding(.top, 1)
    }
    
    @ViewBuilder
    private func cellView(for feedItem: VideosPaginatingFeedViewModel.FeedItem) -> some View {
        let shouldEmbed = viewModel.shouldEmbedPlayer(for: feedItem.id)
        switch feedItem {
        case .inlinePreview(let inlineFeedItem):
            VideoFeedCell(
                feedItem: inlineFeedItem,
                embeddedState: shouldEmbed ? .player(autoPlayOnStart: true) : .placeholder
            )
        case .inlineInteractive(let inlineFeedItem):
            VideoFeedCell(
                feedItem: inlineFeedItem,
                embeddedState: shouldEmbed ? .player(autoPlayOnStart: true) : .placeholder
            )
        }
        
    }
    
    /// Detects scrolling through rapid preference changes without interfering with player interactions
    private func handleScrollDetection() {
        // Cancel existing timer
        scrollDetectionTimer?.invalidate()
        
        // Mark as scrolling if not already
        if !isScrolling {
            isScrolling = true
            Task {
                await viewModel.handleScrollGestureChanged()
            }
        }
        
        // Set timer to detect when scrolling stops
        scrollDetectionTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { _ in
            // Scrolling has stopped (no preference changes for 150ms)
            isScrolling = false
            Task {
                await viewModel.handleScrollGestureEnded()
            }
        }
    }
    
    @ViewBuilder
    private func loadingPlaceholderView(index: Int) -> some View {
        VStack(spacing: 0) {
            // Header placeholder
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 30)
                    .cornerRadius(4)
                    .shimmerEffect(delay: Double(index) * 0.1)
                
                VStack(alignment: .leading, spacing: 4) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 150, height: 16)
                        .cornerRadius(8)
                        .shimmerEffect(delay: Double(index) * 0.1 + 0.2)
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 100, height: 12)
                        .cornerRadius(6)
                        .shimmerEffect(delay: Double(index) * 0.1 + 0.4)
                }
                
                Spacer()
            }
            .padding(8)
            .background(Color.white)
            
            // Video player placeholder
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(16.0/9.0, contentMode: .fit)
                
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(.white)
                    
                    Text("Loading video...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .background(Color.black.opacity(0.1))
        }
        .background(Color.clear)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(resource: .wscAccent).withAlphaComponent(0.4)
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().isTranslucent = true
    }
}
