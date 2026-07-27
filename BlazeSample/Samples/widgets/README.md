# Widgets Module

This module demonstrates the implementation and customization of various widgets within the Blaze Sample iOS application. It provides a showcase of different widget types, their layouts, and editing capabilities, serving as a reference for integrating and managing widgets in an iOS app.

## Main Components

### WidgetsListView
- Navigation view that displays available widget types and routes to different widget screens
- Implemented as SwiftUI view with predefined list of widget options
- Widget types include: Stories Row, Stories Grid, Moments Row, Moments Grid, Videos Row, Videos Grid, Live Video Row, Mixed Widgets Feed
- Features navigation to specific widget demonstrations with descriptive titles

### MixedWidgetsViewController
- Demonstrates multiple widget types in a single scrollable feed
- Manages five different widget types simultaneously: Stories Row, Moments Row, Live Video Row, Videos Row, Stories Grid
- Handles widget lifecycle, pull-to-refresh functionality, and section headers
- Uses WidgetSectionView for proper layout organization
- The Live Video Row widget is shown here with the SDK's default (uncustomized) preset

> The personalized, tabs-backed "Moments Follow Tabs" widget (Follow Entities example) has its own
> dedicated module — see `Samples/FollowEntities/`.

### Widget Screen Controllers
- Individual controllers for each widget type: StoriesRowViewController, StoriesGridViewController, MomentsRowViewController, MomentsGridViewController, VideosRowViewController, VideosGridViewController, LiveVideoRowViewController
- Each controller demonstrates specific widget type with customization options
- Provides editing capabilities through bottom sheet interfaces
- `LiveVideoRowViewController` demonstrates a Videos widget filtered to live/upcoming/ended stream content via `videosFilterParams`, with a customization example for the per-stream-state status indicator (distinct colors for the LIVE/UPCOMING/ENDED badge) - applied to both the widget-cell badge and the full-screen player's own status indicator (`videosPlayerStyle.statusIndicator`), so the customization carries through from feed to player

### WidgetsViewModel
- Centralized configuration management for all widget types
- Manages widget layouts, data sources, and delegate handling
- Provides preset layout configurations for each widget type
- Handles widget data state tracking and style customization

## Editing Options

### Data Source Editing
- Widget labels configured through ConfigManager reading from xcconfig files
- Data source types use BlazeDataSourceType.labels with single label configuration
- Order types support manual ordering with read status prioritization
- Runtime label switching allows dynamic data source changes

### Layout Style Editing
- Preset layouts available for each widget type through BlazeWidgetLayout.Presets
- Custom styling options include spacing, insets, status indicators, and visual property modifications
- Responsive design support with embedded scroll view configuration for grid layouts
- Widget item style customization for image properties, status indicators, and positioning

### Live Video Filtering
- The Live Video Row widget requests both VOD and stream content, across all stream states (`live`, `upcoming`, `ended`), via `BlazeVideosFilterParams(contentTypes: [.video, .stream], streamStates: [.live, .upcoming, .ended])`
- Without this filter, a Videos widget only returns VOD content - streams are opt-in
- Its data source label is configured separately from the regular Videos widgets (`BLAZE_VIDEOS_LIVE_ROW_LABEL`)
- Its data source always sorts with `advancedOrderType: .liveFirst`, so live streams surface ahead of upcoming/ended/VOD content regardless of the base order type

## Usage

1. Navigate to Widgets module from main navigation
2. Configure widget labels in AppConfig.xcconfig (stories_row_label, moments_grid_label, videos_row_label, videos_live_row_label, etc.)
3. Select specific widget type from WidgetsListView
4. Use edit options to customize data source and layout style
5. Pull-to-refresh to reload widget data
6. Observe real-time updates when applying customizations 