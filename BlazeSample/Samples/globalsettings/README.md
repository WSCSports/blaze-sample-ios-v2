# GlobalSettings Module

This module demonstrates how to use and configure global settings in the Blaze SDK within the Blaze Sample iOS application. It provides a UI for setting global parameters that affect all BlazeSDK instances in the app, as well as programmatic configuration for default player styles.

## Main Components

### GlobalSettingsView
- The main entry point for the globalsettings module.
- Provides a SwiftUI interface for configuring global BlazeSDK settings, including:
  - **Do Not Track**: Toggle user tracking on or off for the SDK.
  - **External User ID**: Set an external user ID for the SDK, useful for analytics and user-specific features.
  - **Geo Location**: Update the geo location restriction for the SDK, which can affect content availability.
- **Default Player Styles**: Set the default styles for Blaze Story and Moments players programmatically in code (not via the UI). If not set, the SDK uses its own base styles.
- All operations are performed using the BlazeSDK's global methods and affect all widgets and players in the app.

## Usage

1. **Launch**: The module is launched via `GlobalSettingsView`.
2. **Configure**: Use the UI to set global SDK parameters as needed for your app or testing scenario. Default player styles are set programmatically in the view's code.
3. **Effect**: All changes are applied globally and will affect all BlazeSDK widgets and players in the app. 