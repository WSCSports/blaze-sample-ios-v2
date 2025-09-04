# Widgets Module

This module demonstrates the implementation and customization of various widgets within the Blaze Sample iOS application. It provides a showcase of different widget types, their layouts, and editing capabilities, serving as a reference for integrating and managing widgets in an iOS app.

## Main Components

### WidgetsListView
- Navigation view that displays available widget types and routes to different widget screens
- Implemented as SwiftUI view with predefined list of widget options
- Widget types include: Stories Row, Stories Grid, Moments Row, Moments Grid, Videos Row, Videos Grid, Mixed Widgets Feed
- Features navigation to specific widget demonstrations with descriptive titles

### MixedWidgetsViewController
- Demonstrates multiple widget types in a single scrollable feed
- Manages four different widget types simultaneously: Stories Row, Stories Grid, Moments Row, Videos Row
- Handles widget lifecycle, pull-to-refresh functionality, and section headers
- Uses WidgetSectionView for proper layout organization

### Widget Screen Controllers
- Individual controllers for each widget type: StoriesRowViewController, StoriesGridViewController, MomentsRowViewController, MomentsGridViewController, VideosRowViewController, VideosGridViewController
- Each controller demonstrates specific widget type with customization options
- Provides editing capabilities through bottom sheet interfaces

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

## Usage

1. Navigate to Widgets module from main navigation
2. Configure widget labels in AppConfig.xcconfig (stories_row_label, moments_grid_label, videos_row_label, etc.)
3. Select specific widget type from WidgetsListView
4. Use edit options to customize data source and layout style
5. Pull-to-refresh to reload widget data
6. Observe real-time updates when applying customizations 