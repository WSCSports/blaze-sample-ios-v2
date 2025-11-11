# Videos Inline Module

This module demonstrates how to implement auto-playing video feeds using the BlazeSDK SwiftUI inline player components. It showcases modern SwiftUI patterns for building engaging video feed experiences similar to popular social media apps, with comprehensive examples ranging from basic single players to advanced infinite-scroll feeds with performance monitoring.

## Overview

The Videos Inline module provides multiple examples of implementing video feeds and players with automatic playback, performance optimization, and advanced features. Each example demonstrates different aspects and approaches to video integration, from simple use cases to production-ready implementations.

## Module Structure

```
videosinline/
├── VideosInlineListView.swift          # Main navigation entry point
├── SwiftUI/                            # SwiftUI implementation examples
│   ├── VideosFeedView/                 # Advanced feed implementation
│   │   ├── VideosFeedView.swift        # Main feed view with infinite scroll
│   │   ├── VideosFeedViewModel.swift   # Feed state management
│   │   ├── VideoFeedCell.swift         # Individual video cell
│   │   ├── PlayerControlsView.swift    # Custom player controls
│   │   ├── ShimmerEffect.swift         # Loading animation
│   │   └── CellPositionPreferenceKey.swift  # Scroll tracking
│   ├── VideosFeedExampleView/          # Performance monitoring
│   │   ├── VideosFeedMonitoringView.swift   # Feed with overlay
│   │   ├── PerformanceMonitor.swift    # FPS tracking
│   │   ├── PerformanceOverlay.swift    # Visual performance data
│   │   └── FPSHistoryView.swift        # FPS history chart
│   ├── VideoPlayerExamples.swift       # Collection of player examples
│   ├── VideosFeedComparisonView.swift  # API comparison guide
│   └── Helpers For Clients/            # Helper utilities
│       ├── BlazeSwiftUIVideoFeedInlinePlayerView.swift
│       └── VideoFeedScrollStateManager.swift
└── README.md                           # This file
```

## Components

### Main Navigation

#### VideosInlineListView
- The main entry point for the Videos Inline module
- Lists all available video feed and player examples
- Follows the sample app's navigation pattern
- Provides access to 9 different examples and comparisons

### Advanced Feed Examples

#### VideosFeedView
**Approach #2**: Controller stored in model (outlives view for better performance)
- Production-ready auto-playing video feed
- Features:
  - Infinite scroll with pagination
  - Debounced scroll detection for optimal performance
  - Smart visibility detection (top-half prioritization)
  - LazyVGrid for memory efficiency
  - Shimmer loading placeholders
  - Mix of preview and interactive players
  - Cell position tracking with PreferenceKey
  - Automatic player state management

#### VideosFeedViewModel
- MainActor-isolated state management
- Manages feed items with unique identifiers
- Pagination logic (10 items per page)
- Debounced scroll position updates
- Visibility calculation and playback decisions
- Player controller lifecycle management
- Mock data generation for testing

#### VideosFeedMonitoringView
- Wraps VideosFeedView with performance overlay
- Real-time FPS monitoring
- Debug mode toggle
- Performance metrics visualization
- Demonstrates production debugging tools

### Basic Player Examples

#### VideoPlayerExamples.BasicPlayerExample
**Approach #1**: Controller created with view (player dies when view dies)
- Simple single video player
- State-based embed control (.placeholder vs .player)
- Manual embed and auto-play options
- Basic player lifecycle demonstration

#### VideoPlayerExamples.PlayerControllerExample
- Programmatic player control demonstration
- Resume, pause, fullscreen methods
- Block/unblock interaction examples
- Shows full controller API capabilities

#### VideoPlayerExamples.SimpleFeedExample
- Minimal auto-playing feed implementation
- Uses convenience `.preview()` initializer
- Simple `.videoFeedAutoPlay()` modifier
- Perfect starting point for new integrations

#### VideoPlayerExamples.InteractiveFeedExample
- Feed with custom delegate handling
- Interactive player mode
- Visual feedback for playing state
- Card-based UI design

#### VideoPlayerExamples.ConfigurationObjectExample
- Recommended initialization pattern
- Configuration-based setup
- Toggle between preview/interactive modes
- Dynamic player configuration changes

#### VideoPlayerExamples.CustomConfigurationExample
- Advanced configuration options
- Dynamic video selection
- Adjustable visibility threshold
- Mode switching (preview/interactive)

### Documentation & Comparison

#### VideosFeedComparisonView
- Side-by-side API comparison
- Migration guide from manual implementation
- Benefits breakdown
- Usage examples and best practices
- Links to all example implementations

## Key Features

### Advanced Performance Optimization
VideosFeedView implements production-grade optimizations:
- **Debounced Updates**: Scroll position changes are debounced (200ms) to prevent excessive updates
- **Lazy Loading**: LazyVGrid only renders visible cells
- **Smart Visibility Detection**: Prioritizes cells in top half of viewport
- **Infinite Scroll**: Automatic pagination with loading states
- **Memory Management**: Controllers outlive individual view renders

### Two Controller Approaches

**Approach #1** (BasicPlayerExample, SimpleFeedExample):
- `@StateObject` controller in view
- Controller lifecycle tied to view
- Simpler but recreates on view reconstruction
- Best for: Single players, simple feeds

**Approach #2** (VideosFeedView):
- Controller stored in model
- Controller outlives view changes
- Better performance for scrolling feeds
- Best for: Complex feeds, infinite scroll

### Auto-Play Strategies

**Simple Approach** (SimpleFeedExample, InteractiveFeedExample):
```swift
.videoFeedAutoPlay(threshold: 0.6) { playingVideoId in
    // Automatic visibility tracking
}
```

**Advanced Approach** (VideosFeedView):
- Custom PreferenceKey for position tracking
- Manual visibility calculation
- Top-half prioritization algorithm
- Debounced updates during scroll

### Player Modes

**Preview Mode**:
- Auto-play on visibility
- Tap to enter interactive/fullscreen
- Minimal controls
- Lower resource usage

**Interactive Mode**:
- Full player controls
- Seek bar, volume, fullscreen
- Embedded playback control
- Richer user interaction

## Implementation Patterns

### Simple Feed (Approach #1)
```swift
struct SimpleFeed: View {
    let videos = ["video-1", "video-2", "video-3"]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(videos, id: \.self) { video in
                    BlazeSwiftUIVideoFeedInlinePlayerView.preview(
                        dataSourceType: .labels(.singleLabel(video)),
                        id: video
                    )
                    .aspectRatio(16/9, contentMode: .fit)
                }
            }
        }
        .videoFeedAutoPlay { playingVideoId in
            print("Playing: \(playingVideoId ?? "none")")
        }
    }
}
```

### Advanced Feed (Approach #2)
```swift
@MainActor
class FeedViewModel: ObservableObject {
    @Published var items: [FeedItem] = []
    @Published var currentlyPlaying: String?
    
    func shouldEmbedPlayer(for id: String) -> Bool {
        currentlyPlaying == id
    }
}

struct AdvancedFeed: View {
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.items) { item in
                    VideoCell(
                        item: item,
                        embeddedState: viewModel.shouldEmbedPlayer(for: item.id) 
                            ? .player(autoPlayOnStart: true) 
                            : .placeholder
                    )
                }
            }
        }
        .onPreferenceChange(CellPositionPreferenceKey.self) { positions in
            viewModel.updateVisibleCells(positions)
        }
    }
}
```

### Single Player with Controller
```swift
struct PlayerView: View {
    @StateObject private var controller = BlazeSwiftUIVideoInlinePlayerController()
    @State private var embeddedState: EmbeddedState = .placeholder
    
    var body: some View {
        VStack {
            BlazeSwiftUIVideosInlinePlayerView(
                configuration: .init(
                    playerMode: .interactive(interactivePlyerStyle: .base()),
                    dataSourceType: .labels(.singleLabel("my-video")),
                    containerIdentifier: "player-1"
                ),
                playerController: controller,
                embeddedState: embeddedState
            )
            
            Button("Play") {
                embeddedState = .player(autoPlayOnStart: true)
            }
            
            Button("Pause") {
                controller.pausePlayer()
            }
        }
    }
}
```

## Configuration

### Data Sources
Videos are loaded using label-based data sources from ConfigManager:
- `videos-feed-playlist-1` through `videos-feed-playlist-10`
- Cycled for infinite scroll demonstration
- Each page generates 10 unique items with pagination suffix

### Performance Thresholds

**Simple Auto-Play** (SimpleFeedExample):
- Default threshold: 0.6 (60% visibility)
- Configurable: `.videoFeedAutoPlay(threshold: 0.8)`

**Advanced Detection** (VideosFeedView):
- Top-half prioritization
- >50% in top half = primary candidate
- Fallback to most visible cell
- Special handling near bottom of feed
- 200ms debounce for scroll settle detection

### Pagination Settings
- Items per page: 10
- Pagination threshold: 0pt from bottom (immediate load)
- Simulated network delay: 900ms
- Unique identifiers per page to prevent duplicates

## Benefits

### Multiple Example Approaches
- **9 different examples** covering various use cases
- Simple to advanced implementations
- Both Approach #1 and #2 demonstrated
- Production-ready patterns included

### Simplified Integration
- Drop-in SwiftUI components
- No manual scroll tracking required (simple approach)
- Automatic player state management
- Built-in performance optimizations

### Modern SwiftUI Patterns
- Declarative view composition
- State-driven UI updates (@Published, @StateObject)
- Modifier-based configuration
- MainActor isolation for thread safety
- PreferenceKey for advanced coordinate spaces

### Performance Monitoring
- Real-time FPS tracking
- Performance overlay visualization
- Debug mode for development
- Production-ready monitoring patterns

### Developer Experience
- Minimal boilerplate code (SimpleFeedExample)
- Advanced patterns available (VideosFeedView)
- Clear event handling with delegates
- Comprehensive logging throughout
- Easy to customize and extend
- Side-by-side API comparison guide

## Best Practices

### Choosing an Approach

**Use Approach #1** (Controller in View) when:
- Single player implementations
- Simple feeds with few items
- Quick prototypes
- Learning the API

**Use Approach #2** (Controller in Model) when:
- Complex infinite scroll feeds
- Performance is critical
- Many items (>20)
- Production applications

### General Best Practices

1. **Use LazyVStack/LazyVGrid**: Ensures efficient memory usage for long feeds
2. **Set Appropriate Threshold**: Balance between user experience and performance
3. **Implement Delegates**: Track events for analytics and debugging
4. **Handle State Changes**: Update UI based on playing state
5. **Test on Devices**: Verify performance with real-world scroll speeds
6. **Debounce Updates**: Prevent excessive calculations during scroll (Approach #2)
7. **Monitor Performance**: Use VideosFeedMonitoringView pattern for optimization
8. **Unique Identifiers**: Always use unique IDs for feed items, especially with pagination
9. **Cleanup Resources**: Cancel pending work items in deinit
10. **MainActor Isolation**: Use @MainActor for ViewModels managing UI state

## Quick Start Guide

### 1. Start with Simple Examples
Begin with `SimpleFeedExample` to understand the basics:
- Navigate to Videos Inline → Simple Feed Example
- Examine the minimal code required
- Understand `.videoFeedAutoPlay()` modifier

### 2. Explore Controller API
Check out `PlayerControllerExample`:
- Learn programmatic player control
- See all available controller methods
- Understand state management

### 3. Advanced Feed Implementation
Study `VideosFeedView` for production patterns:
- Infinite scroll implementation
- Performance optimization techniques
- Custom visibility detection
- Proper pagination handling

### 4. Compare Approaches
Review `API Comparison`:
- See original vs new implementation
- Understand migration path
- Learn benefits and trade-offs

### 5. Monitor Performance
Use `VideosFeedMonitoringView`:
- Enable FPS overlay
- Monitor scroll performance
- Identify optimization opportunities

## Example Summary

| Example | Approach | Complexity | Best For |
|---------|----------|------------|----------|
| Basic Player Example | #1 | Low | Learning, single player |
| Player Controller Example | #1 | Low | Understanding controller API |
| Simple Feed Example | #1 | Low | Quick feed implementation |
| Interactive Feed Example | #1 | Medium | Custom delegates, card UI |
| Configuration Object Example | #1 | Low | Recommended init pattern |
| Custom Configuration Example | #1 | Medium | Dynamic configuration |
| Videos Feed | #2 | High | Production infinite scroll |
| Videos Feed Monitoring | #2 | High | Performance debugging |
| API Comparison | N/A | Low | Learning, migration |

## Related Documentation

- BlazeSDK SwiftUI Video Components
- BlazeSwiftUIVideosInlinePlayerView API Reference
- BlazeSwiftUIVideoInlinePlayerController Methods
- Auto-Play Modifier Documentation
- Player Delegate Event Reference
- Performance Optimization Guide

## Architecture Notes

### Controller Lifecycle
- **Approach #1**: `@StateObject` in view - lifecycle tied to view
- **Approach #2**: Stored in model - survives view recreation
- Choose based on use case and performance requirements

### Memory Management
- LazyVStack/LazyVGrid defer cell creation
- Controllers in Approach #2 can accumulate (implement cleanup if needed)
- PreferenceKey updates are efficient with debouncing

### Thread Safety
- ViewModels use `@MainActor` for UI updates
- Async/await for asynchronous operations
- DispatchQueue used for debounced updates

## Troubleshooting

### Videos not auto-playing
- Check visibility threshold setting
- Verify scroll view has proper geometry
- Ensure unique IDs for all items
- Check console for logs

### Performance issues
- Enable VideosFeedMonitoringView overlay
- Check FPS during scroll
- Consider Approach #2 for better performance
- Reduce items per page if needed

### Pagination not triggering
- Verify paginationThreshold setting
- Check scroll position calculations
- Ensure isLoadingMoreItems flag works correctly
- Review console logs for trigger events

## Additional Resources

- All examples include comprehensive logging
- Check console for detailed event tracking
- Compare side-by-side in API Comparison view
- Start simple, progress to advanced as needed

