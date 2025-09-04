# MomentsContainer Module

This module demonstrates how to use and customize the BlazeMomentsPlayerContainer in the Blaze Sample iOS application. It features a simple navigation flow between a home screen and a moments playback screen, providing a reference for integrating and customizing moments playback experiences in your own app.

## Main Components

### MomentsContainerViewController
- The main entry point for the momentscontainer module.
- Sets up the UI and manages navigation between view controllers using a tab bar controller.

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

## BlazeMomentsPlayerContainer Usage

- The `MomentsViewController` contains a `BlazeMomentsPlayerContainer` instance, which is responsible for displaying and playing moments content.
- The container is started as soon as the view controller is loaded, and is styled using parameters from the ViewModel.

## Player Style Customization

The player style for the moments container can be customized using the Blaze SDK. Example customizations include:
- **Buttons**: Show/hide mute and exit buttons.
- **Seek Bar**: Adjust corner radius, thumb visibility, margins, and more for both playing and paused states.
- **CTA Button**: Change layout positioning and appearance.

All customizations are managed in the ViewModel and applied to the BlazeMomentsPlayerContainer instance.

## Usage

1. **Launch**: The module is launched via `MomentsContainerViewController`.
2. **Navigation**: The user starts on the HomeViewController and can navigate to the MomentsViewController to view moments playback.
3. **Customization**: Review the code in `MomentsContainerViewModel.swift` to see how player style properties can be customized using the Blaze SDK. 
