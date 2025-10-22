# MomentsContainer Module

This module demonstrates how to use and customize the BlazeMomentsPlayerContainer in the Blaze Sample iOS application. It features a simple navigation flow between a home screen and moments playback screens, including a new tabbed interface for moments, providing a reference for integrating and customizing moments playback experiences in your own app.

## Main Components

### MomentsContainerViewController
- The main entry point for the moments container module.
- Sets up the UI and manages navigation between view controllers using a tab bar controller.

### MomentsContainerTabsViewController
- Demonstrates the use of `BlazeMomentsPlayerContainerTabs` for tabbed moments playback.
- Features two tabs: "Trending" and "For You" with custom icons and data sources.
- Shows how to configure different container IDs and labels for each tab.

### MomentsHomeViewController
- Serves as the app's home screen within this module.
- Provides navigation to the MomentsViewController via a button.
- Demonstrates proper view controller lifecycle management.

### MomentsViewController
- Demonstrates the use of `BlazeMomentsPlayerContainer` to play moments.
- Instantiates and starts playback of moments when the view controller is loaded.

### MomentsContainerViewModel
- Demonstrates how to customize the BlazeMomentsPlayerStyle for the container.
- Manages state and configuration for the moments container.
- Configures tab items with custom icons, titles, and data sources.
- Provides delegate methods for handling tab selection and player events.

## BlazeMomentsPlayerContainer Usage

- The `MomentsViewController` contains a `BlazeMomentsPlayerContainer` instance, which is responsible for displaying and playing moments content.
- The container is started as soon as the view controller is loaded, and is styled using parameters from the ViewModel.

## BlazeMomentsPlayerContainerTabs Usage

- The `MomentsContainerTabsViewController` demonstrates the use of `BlazeMomentsPlayerContainerTabs` for creating a tabbed moments experience.
- Each tab is configured with:
  - Unique container ID for data source identification
  - Custom title and icons (selected/unselected states)
  - Data source configuration using labels
  - Ads configuration type
- The tabs container includes `BlazePlayerTabsStyle.base()` for customizing the appearance of the tab bar itself.
- The tabs container is started automatically when the view controller loads.

## Player Style Customization

The player style for the moments container can be customized using the Blaze SDK. Example customizations include:
- **Buttons**: Show/hide mute and exit buttons.
- **Seek Bar**: Adjust corner radius, thumb visibility, margins, and more for both playing and paused states.
- **CTA Button**: Change layout positioning and appearance.

All customizations are managed in the ViewModel and applied to the BlazeMomentsPlayerContainer instance.

## Tabs Style Customization

The tabs container also supports styling through `BlazePlayerTabsStyle`:
- **Tab Bar Appearance**: Customize the overall look and feel of the tab bar
- **Tab Selection**: Configure how selected and unselected tabs appear
- **Tab Layout**: Adjust spacing, alignment, and positioning of tabs

The tabs style is configured using `BlazePlayerTabsStyle.base()` and can be further customized to match your app's design requirements.

## Usage

1. **Launch**: The module is launched via `MomentsContainerViewController`.
2. **Navigation**: The user starts on the HomeViewController and can navigate to different moments playback screens:
   - **MomentsViewController**: Single moments container for basic playback
   - **MomentsContainerTabsViewController**: Tabbed interface with "Trending" and "For You" tabs
3. **Tab Configuration**: Each tab in the tabs container can be configured with:
   - Different data sources and labels
   - Custom icons for selected and unselected states
   - Unique container IDs for content identification
   - Individual ads configuration
4. **Customization**: Review the code in `MomentsContainerViewModel.swift` to see how player style properties and tab configurations can be customized using the Blaze SDK. 
