# SwiftUI Module

This module demonstrates how to use SwiftUI with the Blaze SDK in the Blaze Sample iOS application. It showcases the integration of Blaze widgets and player containers using modern SwiftUI patterns, including navigation, state management, and reactive programming.

## Main Components

### SwiftUIWidgetsTabView
- The main entry point for the SwiftUI module.
- Sets up the SwiftUI navigation, tab bar, and theming.
- Provides navigation between different SwiftUI screens.

### Screens
- **SwiftUIWidgetsView**: Displays Blaze Stories Row, Moments Row, and Stories Grid widgets using SwiftUI.
- **SwiftUIWidgetsMomentsContainerView**: Displays the Blaze Moments Player Container using SwiftUI.
- **SwiftUIWidgetsWidgetsFeedView**: Shows a feed of various Blaze widgets in a scrollable view.

### SwiftUIWidgetsViewModel
- Manages state and handlers for Blaze widgets and player containers.
- Provides state handlers for stories row, moments row, stories grid, and the moments player container.
- Implements `ObservableObject` for reactive state management.
- Handles widget configuration and data loading.


## SwiftUI Integration Patterns
- **State Management**: Uses `@StateObject`, `@ObservedObject`, and `@Published` for reactive state updates.
- **View Composition**: Demonstrates proper SwiftUI view composition with Blaze widgets.
- **Lifecycle Management**: Handles widget lifecycle using SwiftUI's `onAppear` and `onDisappear` modifiers.

## Usage

1. **Launch**: The module is launched via `SwiftUIWidgetsTabView`.
2. **Navigate**: Use the tab navigation to switch between different SwiftUI screens.
3. **Interact**: View and interact with Blaze widgets and player containers, all rendered using SwiftUI.
4. **State Updates**: Observe how state changes are automatically reflected in the UI through SwiftUI's reactive system. 
