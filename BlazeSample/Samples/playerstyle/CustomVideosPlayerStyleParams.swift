//
//  CustomVideosPlayerStyleParams.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 02/07/2025.
//

import UIKit
import BlazeSDK

struct CustomVideosPlayerStyleConstants {
    static let headerTextSize: CGFloat = 22
    static let descriptionTextSize: CGFloat = 16
    static let progressBarColor = UIColor(named: "wsc_accent")!
    static let backgroundColor = UIColor(hex: "181820") ?? .black
}

extension BlazeVideosPlayerStyle {
    
    static func customVideosPlayerStyle() -> BlazeVideosPlayerStyle {
        var style = BlazeVideosPlayerStyle.base()
                
        // Apply custom seek bar style
        style.applyCustomSeekBarStyle()
        
        // Apply custom CTA button style
        style.applyCustomCtaStyle()
        
        // Apply custom buttons style
        style.applyCustomVideosButtonsStyle()
                
        return style
    }
}

extension BlazeVideosPlayerStyle {
    
    mutating func applyCustomSeekBarStyle() {
        // Configure seek bar visibility and spacing
        seekBar.bottomSpacing = 16
        seekBar.horizontalSpacing = 16
        
        // Playing state configuration - when video is playing
        seekBar.playingState.isVisible = true
        seekBar.playingState.backgroundColor = CustomVideosPlayerStyleConstants.progressBarColor.withAlphaComponent(0.3)
        seekBar.playingState.progressColor = CustomVideosPlayerStyleConstants.progressBarColor
        seekBar.playingState.cornerRadius = 2
        seekBar.playingState.height = 4
        seekBar.playingState.isThumbVisible = false
        seekBar.playingState.thumbSize = 10
        
        // Paused state configuration - when video is paused
        seekBar.pausedState.isVisible = true
        seekBar.pausedState.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        seekBar.pausedState.progressColor = CustomVideosPlayerStyleConstants.progressBarColor
        seekBar.pausedState.thumbColor = CustomVideosPlayerStyleConstants.progressBarColor
        seekBar.pausedState.cornerRadius = 4
        seekBar.pausedState.height = 8
        seekBar.pausedState.thumbSize = 14
        seekBar.pausedState.isThumbVisible = true
    }
    
    mutating func applyCustomCtaStyle() {
        // Basic CTA button appearance
        cta.cornerRadius = 20
        cta.font = .systemFont(ofSize: 16, weight: .semibold)
        cta.width = 120
        cta.height = 40
        
        // Configure CTA visibility behavior
        // Option 1: Always visible (recommended for most use cases)
        cta.ctaVisibility = .alwaysVisible
        
        // Option 2: Visible for 3 seconds after overlay is hidden
        // cta.ctaVisibility = .visibleAfterOverlayHidden(for: 3.0)
        
        // Set play icon for CTA button if available
        if let playIcon = UIImage(named: "ic_play_cta") {
            cta.icon = playIcon
        }
    }
    
    mutating func applyCustomVideosButtonsStyle() {
        // Exit button configuration
        buttons.exit.isVisible = true
        buttons.exit.color = .white
        buttons.exit.width = 48
        buttons.exit.height = 48
        buttons.exit.isVisibleForAds = false
        buttons.exit.contentHorizontalAlignment = .center
        buttons.exit.contentVerticalAlignment = .center
        
        // Set exit button custom image
        if let exitImage = UIImage(named: "ic_rounded_close") {
            buttons.exit.customImage = .init(default: exitImage, selected: nil)
        }

        // Share button configuration
        buttons.share.isVisible = true
        buttons.share.color = .white
        buttons.share.width = 48
        buttons.share.height = 48
        buttons.share.isVisibleForAds = true
        buttons.share.contentHorizontalAlignment = .center
        buttons.share.contentVerticalAlignment = .center
        
        // Set share button custom image
        if let shareImage = UIImage(named: "ic_share") {
            buttons.share.customImage = .init(default: shareImage, selected: shareImage)
        }

        // Mute button configuration
        buttons.mute.isVisible = true
        buttons.mute.color = .white
        buttons.mute.width = 48
        buttons.mute.height = 48
        buttons.mute.isVisibleForAds = true
        buttons.mute.contentHorizontalAlignment = .center
        buttons.mute.contentVerticalAlignment = .center
        
        // Set mute button custom images for both states
        if let muteOffImage = UIImage(named: "ic_sound_off"), let muteOnImage = UIImage(named: "ic_sound_on") {
            buttons.mute.customImage = .init(default: muteOnImage, selected: muteOffImage)
        }
        
        // Like button configuration
        buttons.like.isVisible = true
        buttons.like.color = .white
        buttons.like.width = 48
        buttons.like.height = 48
        buttons.like.isVisibleForAds = true
        buttons.like.contentHorizontalAlignment = .center
        buttons.like.contentVerticalAlignment = .center
        
        // Set like button custom images for both states
        if let likeSelectedImage = UIImage(named: "ic_like_selected"), let likeUnselectedImage = UIImage(named: "ic_like_unselected") {
            buttons.like.customImage = .init(default: likeUnselectedImage, selected: likeSelectedImage)
        }
        
        // Play/Pause button configuration
        buttons.playPause.isVisible = true
        buttons.playPause.color = .white
        buttons.playPause.width = 48
        buttons.playPause.height = 48
        buttons.playPause.isVisibleForAds = false
        buttons.playPause.contentHorizontalAlignment = .center
        buttons.playPause.contentVerticalAlignment = .center
        
        // Set play/pause button custom image
        if let playButtonImage = UIImage(named: "ic_play") {
            let pauseImageConfig = UIImage.SymbolConfiguration(pointSize: 48, weight: .medium)
            let pauseImage = UIImage(systemName: "pause.circle.fill", withConfiguration: pauseImageConfig)
            buttons.playPause.customImage = .init(default: playButtonImage, selected: pauseImage)
        }
        
        // Previous video button configuration
        buttons.previous.isVisible = true
        buttons.previous.color = .white
        buttons.previous.width = 48
        buttons.previous.height = 48
        buttons.previous.isVisibleForAds = false
        buttons.previous.contentHorizontalAlignment = .center
        buttons.previous.contentVerticalAlignment = .center
        
        // Set previous button custom image
        let previousImageConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        if let previousImage = UIImage(systemName: "arrow.left", withConfiguration: previousImageConfig) {
            buttons.previous.customImage = .init(default: previousImage, selected: nil)
        }
        
        // Next video button configuration
        buttons.next.isVisible = true
        buttons.next.color = .white
        buttons.next.width = 48
        buttons.next.height = 48
        buttons.next.isVisibleForAds = false
        buttons.next.contentHorizontalAlignment = .center
        buttons.next.contentVerticalAlignment = .center
        
        // Set next button custom image
        let nextImageConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        if let nextImage = UIImage(systemName: "arrow.right", withConfiguration: nextImageConfig) {
            buttons.next.customImage = .init(default: nextImage, selected: nil)
        }
    }
}
