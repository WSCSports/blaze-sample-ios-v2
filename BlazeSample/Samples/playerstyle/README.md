# PlayerStyle Module

This module demonstrates how to use and customize Blaze player styles for Stories, Moments, and Videos widgets in the Blaze Sample iOS application. It showcases both the default and custom player styles, providing a reference for integrating and customizing player experiences in your own app.

## Main Components

### PlayerStyleViewController
- The main entry point for the playerstyle module.
- Sets up the UI and initializes six widgets demonstrating default and custom player styles.
- Widget types include: Stories Row (default and custom), Moments Row (default and custom), Videos Row (default and custom).
- Each widget demonstrates either the default Blaze SDK player style or a fully customized implementation.
- Uses `MixedWidgetsView` as the base UI container with `WidgetSectionView` for proper layout organization.

### PlayerStyleViewModel
- Provides the data sources, widget layouts, and player style parameters for the view controller.
- Manages custom player style instances for all three widget types.
- Separates default and custom player style logic through conditional implementation.
- Handles widget state and configuration loading from ConfigManager.

### Custom Player Style Implementation Files

#### CustomStoryPlayerStyleParams.swift
- Contains customization logic for Stories player style.
- Implements button configurations including custom action buttons with stack ordering.
- Provides chip styling for 'LIVE' and 'AD' indicators with text, color, and background customization.
- Includes first time slide onboarding overlay with fully customizable CTA, titles, and instruction sets.
- Configures header gradient and progress bar styling.

#### CustomMomentsPlayerStyleParams.swift
- Contains customization logic for Moments player style.
- Implements extended button configurations including like, play, and caption buttons.
- Provides seek bar customization for both playing and paused states with different visual appearances.
- Includes header and footer gradient configurations with positioning control.
- Features advanced first time slide customization with multiple instruction types and custom instruction support.

#### CustomVideosPlayerStyleParams.swift
- Contains customization logic for Videos player style.
- Implements video-specific button set: mute, exit, share, like, playPause, previous, next.
- Provides CTA button customization with visibility control options (always visible or timed).
- Includes seek bar optimization specifically designed for video playback experience.
- Integrates both custom assets and system SF Symbols with proper sizing configuration.

## Player Style Customization Options

### Stories Player Style
- Background color customization
- Title and last update text styling (color, size, font)
- Player buttons configuration (exit, share, mute, captions, custom action buttons)
- Chip styling for 'LIVE' and 'AD' indicators
- CTA button appearance (corner radius, text size, font)
- Header gradient configuration
- Progress bar color customization
- First time slide onboarding overlay with comprehensive customization options

### Moments Player Style
- Background color and text overlay customization
- Heading and body text styling (color, size, font, visibility)
- Extended player buttons (exit, share, mute, like, play, captions, custom action buttons)
- Chip styling for 'AD' indicators
- CTA button with icon and alignment options
- Header and footer gradient configuration with positioning
- Seek bar appearance for playing and paused states
- Advanced first time slide with multiple instruction types

### Videos Player Style
- Player buttons specific to video content (seven button types available)
- CTA button with visibility behavior control
- Seek bar customization for video playback optimization
- Asset integration using both custom app icons and system SF Symbols
- Consistent color theming using app accent color

**Note**: Videos player style has limitations compared to Stories and Moments players. It does not support background color customization, text overlays, chip indicators, first time slide onboarding, or gradient configurations.

## Asset and Configuration Dependencies

The module utilizes various custom icons from the app's Assets.xcassets including universal icons (ic_rounded_close, ic_play_cta, ic_share), video-specific icons (ic_like_selected/unselected, ic_sound_on/off, ic_play), and navigation icons (ic_back_button, chevron_left). System SF Symbols are used for pause and arrow navigation with custom sizing configuration.

All player styles use the app's accent color (`wsc_accent`) from Assets.xcassets for progress bars, button highlights, and CTA styling to maintain consistent visual branding across all player types.

## Usage

1. **Launch**: Navigate to the PlayerStyle module from the main application navigation.
2. **Configuration**: Ensure required assets are available in Assets.xcassets and accent color is defined.
3. **Customization**: Review and modify the custom player style implementation files to adjust styling parameters.
4. **Testing**: Use the demo widgets to verify both default and custom player style implementations.
5. **Integration**: Apply the customization patterns from the sample files to your own widget implementations.

