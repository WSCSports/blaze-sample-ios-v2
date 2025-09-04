# Blaze Sample

## Overview

The Blaze Sample provides practical examples of how to integrate WSC Sports' BlazeSDK into your iOS application. It includes multiple sample modules that demonstrate different aspects of the SDK, from basic widget implementation to advanced features like universal links, push notifications, and custom styling.

## Setup Instructions

### 1. Clone the Repository

Download the project zip file or clone the repository using git:

```bash
git clone https://github.com/WSCSports/blaze-sample-ios-v2.git
cd blaze-sample-ios-v2
```

### 2. Configure API Key

The BlazeSDK requires an API key to function. You need to add your API key to the `AppConfig.xcconfig` file:

1. Open the `BlazeSample/Core/AppConfig.xcconfig` file
2. Replace the `BLAZE_API_KEY` value with your API key:

```xcconfig
// BlazeSDK API Key
BLAZE_API_KEY = your_api_key_here
```

### 3. Open Project in Xcode

1. Open `blaze-sample-ios-v2.xcodeproj` in Xcode
2. Ensure the correct Development Team is selected and Bunde Id is confugurated
3. Select a target device or simulator

### 4. Build and Run

1. Connect an iOS device or start a simulator
2. Click the "Build and Run" button (⌘+R)

## BlazeSDK Integration Guide

### Initialize the SDK

The BlazeSDK is initialized through a dedicated `BlazeSDKInteractor` singleton class that manages the SDK lifecycle and configuration. Here's how the initialization is structured:

**1. SwiftUI App initialization:**
```swift
// In BlazeSampleApp.swift
import SwiftUI

@main
struct BlazeSampleApp: App {
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AppNavigatorView(viewFactory: DefaultAppViewFactory())
        }
    }
        
    init() {
        BlazeSDKInteractor.shared.initBlazeSDK()
    }
}
```

**2. BlazeSDKInteractor implementation:**
```swift
// BlazeSDKInteractor.swift
import BlazeSDK

final class BlazeSDKInteractor {
    static var shared: BlazeSDKInteractor = BlazeSDKInteractor()
    private let blazeSdk = Blaze.shared
    
    func initBlazeSDK() {
        blazeSdk.initialize(
            apiKey: ConfigManager.blazeApiKey,
            cachingSize: ConfigManager.defaultCacheSize,
            prefetchingPolicy: .Default,
            geo: nil
        ) { [weak self] result in
            self?.handleBlazeSdkInitalResult(for: result)
        }
        
        setupBlazeGlobalDelegate()
    }
    
    private func handleBlazeSdkInitalResult(for result: BlazeResult) {
        switch result {
        case .success:
            Logger.shared.log("SDK initialized successfully!")
        case .failure(let error):
            Logger.shared.log("Error message in blaze sdk: \(error.errorMessage)", level: .error)
        }
    }
}
```

**3. Configuration management:**
```swift
// ConfigManager.swift
enum ConfigManager {
    static var blazeApiKey: String {
        getValue(for: "BLAZE_API_KEY")
    }
    
    static var defaultCacheSize: Int {
        Int(getValue(for: "BLAZE_CACHE_SIZE")) ?? 500
    }
    
    private static func getValue(for key: String) -> String {
        guard let value = Bundle.main.infoDictionary?[key] as? String else {
            fatalError("Missing config value for key: \(key)")
        }
        return value
    }
}
```

This architecture provides:
- **Centralized configuration**: All SDK settings are managed through xcconfig files
- **Error handling**: Proper initialization result handling with logging
- **Singleton pattern**: Single point of SDK interaction throughout the app
- **Delegate management**: Automatic setup of global SDK delegates
- **Firebase integration**: Uses UIApplicationDelegateAdaptor for Firebase setup
- **Lazy initialization**: SDK is initialized when the main view appears, ensuring proper app lifecycle

### Dependencies

BlazeSDK can be integrated using multiple approaches:

| Integration Type | Instructions |
|------------------|-------------|
| Swift Package Manager | [Instructions](https://dev.wsc-sports.com/docs/ios-sdk-integration#/swift-package-manager-integration) |
| CocoaPods | [Instructions](https://dev.wsc-sports.com/docs/ios-sdk-integration#/cocoapods-integration) |
| XCFrameworks | [Instructions](https://dev.wsc-sports.com/docs/ios-sdk-integration#/manual-framework-integration) |

## Available Samples

### 🎛️ Widgets (`Samples/widgets/`)

**What it demonstrates**:
- Implementation of various widget types (Stories, Moments, Videos)
- Row and Grid layout options
- Mixed widgets (multiple widgets on the same screen)
- Runtime editing capabilities:
  - Data source editing (label names, order types)
  - Layout style customization
  - Real-time UI updates

**Key Features**:
- Custom appearance settings
- Status indicators
- Badge management
- Item style overrides

### 🚀 Entry Point (`Samples/entrypoint/`)

**What it demonstrates**:
- Universal links handling
- Push notification integration
- Direct content playback (stories, moments, videos)
- Firebase Cloud Messaging integration

**Key Features**:
- Universal link simulation
- Play content by label expression
- Play single items by ID

### 🎨 SwiftUI (`Samples/swiftUI/`)

**What it demonstrates**:
- SwiftUI integration with BlazeSDK
- Modern UI implementation patterns
- Declarative UI approach for Blaze widgets

### 📺 Ads (`Samples/ads/`)

**What it demonstrates**:
- Advertisement integration within Blaze content
- Ad placement and management

**Key Features**:
- Google Ad Manager integration for custom native and banner ads (GAM)
- Interactive Media Ads integration (IMA)

### 🎬 Player Style (`Samples/playerstyle/`)

**What it demonstrates**:
- Custom player appearance
- Style overrides and theming
- Player behavior customization

### 📱 Moments Container (`Samples/momentscontainer/`)

**What it demonstrates**:
- Moments container implementation
- Container-specific features and customization

### ⚙️ Global Settings (`Samples/globalsettings/`)

**What it demonstrates**:
- SDK-wide configuration options
- Global behavior settings
- Centralized customization

## xcconfig Configuration

The project uses the `AppConfig.xcconfig` file for SDK parameter configuration:

```xcconfig
// BlazeSDK API Key
BLAZE_API_KEY = your_api_key

// Labels for different widgets
BLAZE_STORIES_ROW_LABEL = stories-main
BLAZE_STORIES_GRID_LABEL = stories-main
BLAZE_MOMENTS_ROW_LABEL = moments-main
BLAZE_MOMENTS_GRID_LABEL = moments-main
BLAZE_VIDEOS_ROW_LABEL = video-long-form
BLAZE_VIDEOS_GRID_LABEL = video-long-form

// Ad settings
BLAZE_AD_UNIT = /123456789/CustomNativeUnitTest
BLAZE_TEMPLATE_ID = 123456

// Cache settings
BLAZE_CACHE_SIZE = 500
```

## Troubleshooting

### Common Issues

1. **API Key Not Working**:
   - Verify the API key is correctly added to `AppConfig.xcconfig`
   - Ensure the key format matches: `BLAZE_API_KEY = your_key`
   - Check that the key is valid and not expired

2. **Build Errors**:
   - Ensure iOS SDK is updated to the latest version
   - Clean the project (⌘+Shift+K) and rebuild
   - Check internet connection for dependency downloads

3. **Runtime Errors**:
   - Verify the BlazeSDK is properly initialized
   - Check Xcode console for specific error messages
   - Ensure minimum SDK requirements are met

### Getting Help

- Check individual sample README files for module-specific guidance
- Review the BlazeSDK documentation
- Contact WSC Sports support for API key issues

## System Requirements

- iOS 13.0 or higher
- Xcode 13.0 or higher
- Swift 5.5 or higher

## License

This project is licensed under the terms specified in the LICENSE file.

---

**Note**: Each sample module contains its own detailed README with specific implementation details and usage instructions. Navigate to the respective sample directories for more information. 
