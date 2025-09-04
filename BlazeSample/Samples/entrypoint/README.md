# Entrypoint Module

This module serves as the main entry point for Blaze SDK integration in the Blaze Sample iOS application. It demonstrates how to handle universal links, push notifications, and direct playback of stories, moments, and videos without using widgets.

## Main Components

### EntryPointViewController
- The main view controller for the entrypoint module.
- Handles universal links (via URL scheme handling) and push notifications (via delegate methods).
- Provides a UI for:
  - Simulating universal link handling.
  - Playing stories, moments, and videos by label expression.
  - Playing a single story, moment, or video by ID.
- Optionally prepares Blaze players for stories, moments, and videos on launch for improved performance.
- Demonstrates BlazeSDK methods for handling links, notifications, and direct playback.

### PushNotificationHandler
- Handles push notifications when the app is in the foreground or background.
- Passes Blaze-related payloads to the BlazeSDK for processing.
- Implements proper notification delegate methods for iOS.

## Unique Implementation Details

### Player Preparation (Optional)
- The module demonstrates the optional use of Blaze SDK prepare methods (`prepareStories`, `prepareMoments`, `prepareVideos`).
- These methods allow for pre-loading and caching content to improve performance when playing content later.
- **Note**: Preparation methods are **optional** and not mandatory for basic SDK functionality.
- They are called during view controller initialization to demonstrate best practices for performance optimization.
- Each prepare method accepts a `BlazeDataSourceType` that defines which content to pre-load.

### Firebase Cloud Messaging (FCM) Integration
- The module includes a sample implementation of Firebase messaging handling (`PushNotificationHandler`) to handle push notifications.
- When a push notification is received while the app is in the foreground or background, the handler checks if the payload is relevant for BlazeSDK and passes it for processing.
- Uses `UIApplicationDelegateAdaptor` pattern for SwiftUI integration with Firebase.
- To use FCM, ensure you add your own `GoogleService-Info.plist` file to the app bundle.

### Universal Links Scheme in Info.plist
- The Info.plist is configured with URL schemes for `EntryPointViewController` to support universal links.
- The configuration includes the `CFBundleURLSchemes` with supported schemes (`blazesample`) and domains.
- This allows the app to be opened directly from supported links and route users to the appropriate content via BlazeSDK.
- Also supports universal link domains configured in app entitlements.

## UI Overview
- Simulate a universal link to test deep linking.
- Input fields and play buttons for stories, moments, and videos by label expression.
- Play buttons for single story, moment, or video by ID.
- All actions interact with the BlazeSDK directly.

## Usage

1. **Launch**: The module is launched via `EntryPointViewController` or `EntryPointView`.
2. **Universal Links**: Open the app via a universal link or use the UI to simulate one that opens story/moment/video player directly.
3. **Push Notifications**: Send a push notification with Blaze payload; the handler and view controller will handle it.
4. **Direct Playback**: Use the UI to play stories, moments, or videos by label or ID. 
