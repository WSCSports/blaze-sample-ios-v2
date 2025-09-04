# Ads Module

This module demonstrates how to integrate and configure ads using the Blaze SDK in the Blaze Sample iOS application. It showcases enabling Blaze ad handlers for IMA, GAM custom native, and GAM banner ads, and provides sample delegate implementations for handling ad events.

## Main Components

### AdsViewController
- The main entry point for the ads module.
- Demonstrates how to enable Blaze SDK ads for IMA, GAM custom native, and GAM banner ads through the ViewModel.
- Initializes three Blaze widgets with different ads configuration types:
  - **Stories Row Widget**: Uses `.everyXStories` ads config type
  - **Moments Row Widget**: Uses `.everyXMoments` ads config type  
  - **Stories Grid Widget**: Uses `.firstAvailableAdsConfig` ads config type
- Uses `MixedWidgetsView` as the base UI container with `WidgetSectionView` for each widget.
- Implements widget configuration with data sources, layouts, and identifiers.

### AdsViewModel
- Manages the state and configuration for all ad types.
- Provides the main `enableBlazeSDKAds()` method that initializes all three ad handlers.
- Creates and manages delegate instances for IMA, GAM banner, and GAM custom native ads.
- Handles ad lifecycle management including optional `disableBlazeSDKAds()` cleanup.
- Uses `ConfigManager.adUnit` and `ConfigManager.templateId` for configuration.

### Delegate Implementations
- **AdsViewModel+BlazeIMADelegate**: Handles Interactive Media Ads events, errors, custom settings, and tag URL overrides.
- **AdsViewModel+BlazeGAMBannerAdsDelegate**: Manages Google Ad Manager banner ad events and error handling.
- **AdsViewModel+BlazeGAMCustomNativeAdsDelegate**: Handles custom native ad events, targeting properties, publisher IDs, and network extras.

## Blaze Ad Handler Initialization

The ads initialization follows this sequence:

1. **Enable GAM Custom Native Ads**: Configure custom native ads with ad unit and template ID from ConfigManager, providing the appropriate delegate.

2. **Enable IMA Ads**: Initialize Interactive Media Ads with the IMA delegate for video ad insertion.

3. **Enable GAM Banner Ads**: Set up banner ads with the banner ads delegate for display advertising.

**Key Points**:
- Ad handlers must be enabled before widget initialization.
- Each widget can be configured with different `adsConfigType` values.
- Delegates provide hooks for logging, error handling, and advanced customization.
- Configuration values are loaded from `AppConfig.xcconfig` via `ConfigManager`.
- Ads remain active for the app lifecycle unless explicitly disabled.

## Widget Ads Configuration Types

- **`.everyXStories`**: Shows ads interspersed with stories content
- **`.everyXMoments`**: Shows ads interspersed with moments content  
- **`.firstAvailableAdsConfig`**: Uses the first available ads configuration

## Usage

1. **Launch**: The module is launched via `AdsViewController`.
2. **Enable Ads**: Ads are enabled automatically in `viewDidLoad()` and remain active until disabled.
3. **View Widgets**: Interact with three different Blaze widgets configured to display ads with different strategies.
4. **Handle Events**: Review delegate implementations in extension files for logging and customization examples. 
