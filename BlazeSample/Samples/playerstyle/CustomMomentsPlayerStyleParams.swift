//
//  CustomMomentsPlayerStyleParams.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 02/07/2025.
//

import UIKit
import BlazeSDK

struct PlayerStyleConstants {
    static let headerTextSize: CGFloat = 22
    static let descriptionTextSize: CGFloat = 16
    static let seekBarPlayedSegmentColor = UIColor(hex: "FF6B35") ?? .orange
    static let seekBarUnplayedSegmentColor = UIColor(hex: "CCCCCC") ?? .lightGray
    static let liveChipBgColor = UIColor(hex: "FF0000") ?? .red
    static let adChipBgColor = UIColor(hex: "FFA500") ?? .orange
}

extension BlazeMomentsPlayerStyle {
    
    static func customMomentsPlayerStyle() -> BlazeMomentsPlayerStyle {
        var style = BlazeMomentsPlayerStyle.base()
        return style.applyCustomMomentsPlayerParams()
    }
    
    mutating func applyCustomMomentsPlayerParams() -> BlazeMomentsPlayerStyle {
        let bgColor = UIColor(hex: "181820") ?? .black
        self.backgroundColor = bgColor
        
        // Title appearance
        self.headingText.textColor = .white
        self.headingText.font = .systemFont(ofSize: 16, weight: .regular)
        self.headingText.isVisible = false
        self.headingText.contentSource = .title
        
        // Description appearance
        self.bodyText.textColor = .white
        self.bodyText.font = .systemFont(ofSize: 16, weight: .regular)
        self.bodyText.isVisible = true
        self.bodyText.contentSource = .title

        // Player buttons appearance
        applyButtonsStyle()
        
        // Player chips appearance
        applyChipsStyle()
        
        // CTA button appearance
        self.cta.cornerRadius = 8
        self.cta.font = .systemFont(ofSize: 16, weight: .semibold)
        self.cta.width = 112
        self.cta.height = 36
        self.cta.icon = UIImage(named: "ic_play_cta")?.withTintColor(.white)
        self.cta.layoutPositioning = .ctaNextToBottomButtonsBox
        self.cta.horizontalAlignment = .leading

        self.playerDisplayMode = .fixedRatio_9_16

        // Bottom Components Alignment
        self.bottomComponentsAlignment = .relativeToContainer
                
        // Player header gradient appearance
        self.headerGradient.isVisible = true
        self.headerGradient.startColor = bgColor.withAlphaComponent(0.9)
        self.headerGradient.endColor = .clear
        
        // Player footer gradient appearance
        self.footerGradient.isVisible = true
        self.footerGradient.startColor = .clear
        self.footerGradient.endColor = bgColor.withAlphaComponent(0.9)
        self.footerGradient.endPositioning = .bottomToPlayer
        
        // Player seek bar appearance
        applySeekBarStyle()
        
        // First time slide appearance
        applyFirstTimeSlideStyle()
        
        // Follow entity style appearance
        applyFollowEntityStyle()
        
        return self
    }
    
    mutating func applyButtonsStyle() {
        // Exit button appearance
        buttons.exit.isVisible = true
        buttons.exit.color = .white
        buttons.exit.isVisibleForAds = true
        buttons.exit.contentHorizontalAlignment = .center
        buttons.exit.contentVerticalAlignment = .center
        buttons.exit.width = 48
        buttons.exit.height = 48
        
        // Button images state appearance
        if let exitImage = UIImage(named: "ic_rounded_close") {
            buttons.exit.customImage = .init(default: exitImage, selected: nil)
        }
        
        // Share button appearance
        buttons.share.isVisible = true
        buttons.share.color = .white
        buttons.share.isVisibleForAds = true
        buttons.share.width = 48
        buttons.share.height = 48
        
        // Button images state appearance
        if let shareImage = UIImage(named: "ic_share") {
            buttons.share.customImage = .init(default: shareImage, selected: shareImage)
        }
        
        // Mute button appearance
        buttons.mute.isVisible = true
        buttons.mute.color = .white
        buttons.mute.isVisibleForAds = true
        buttons.mute.width = 48
        buttons.mute.height = 48
        
        // Button images state appearance
        if let muteOffImage = UIImage(named: "ic_sound_off"), let muteOnImage = UIImage(named: "ic_sound_on") {
            buttons.mute.customImage = .init(default: muteOnImage, selected: muteOffImage)
        }
        
        // Like button appearance
        buttons.like.isVisible = true
        buttons.like.color = .white
        buttons.like.isVisibleForAds = true
        buttons.like.width = 48
        buttons.like.height = 48
        
        // Button images state appearance
        if let likeSelectedImage = UIImage(named: "ic_like_selected"), let likeUnselectedImage = UIImage(named: "ic_like_unselected") {
            buttons.like.customImage = .init(default: likeUnselectedImage, selected: likeSelectedImage)
        }
        
        // Like button appearance
        buttons.play.isVisible = true
        buttons.play.color = .white
        buttons.play.isVisibleForAds = false
        buttons.play.width = 48
        buttons.play.height = 48
        
        // Button images state appearance
        if let playButtonImage = UIImage(named: "ic_play") {
            buttons.play.customImage = .init(default: playButtonImage, selected: nil)
        }
        
        // Captions button appearance
        buttons.captions.isVisible = true
        
        var custom1 = BlazeMomentsPlayerCustomActionButton(
            customParams: .init(
                id: "custom1",
                appMetadata: [:],
                name: "My custom 1"
            )
        )
        
        if let customButtonImage = UIImage(named: "ic_custom_player_button") {
            custom1.style.customImage = .init(default: customButtonImage, selected: nil)
        }
        
        // Custom buttons declaration
        buttons.setBottomStackCustomActionButtons([custom1])
        
        // Set custom buttons
        buttons.setBottomStackOrder([
            .captions,
            .share,
            .like,
            .customAction(id: custom1.customParams.id)
        ])
    }

    mutating func applyChipsStyle() {
        // Ad chip appearance
        chips.ad.text = "AD"
        chips.ad.textColor = .white
        chips.ad.backgroundColor = .yellow
        chips.ad.titlePadding.leading = 12
        chips.ad.titlePadding.trailing = 12
        chips.ad.titlePadding.top = 2
        chips.ad.titlePadding.bottom = 2
    }

    mutating func applySeekBarStyle() {
        seekBar.isVisible = true
        seekBar.bottomSpacing = 0
        seekBar.horizontalSpacing = 0
        
        // Playing state
        seekBar.playingState.isVisible = true
        seekBar.playingState.backgroundColor = PlayerStyleConstants.seekBarUnplayedSegmentColor
        seekBar.playingState.progressColor = PlayerStyleConstants.seekBarPlayedSegmentColor
        seekBar.playingState.thumbImage = nil
        seekBar.playingState.cornerRadius = 2
        seekBar.playingState.isThumbVisible = false
        seekBar.playingState.height = 4
        seekBar.playingState.thumbSize = 10
        
        // Paused state
        seekBar.pausedState.isVisible = true
        seekBar.pausedState.backgroundColor = PlayerStyleConstants.seekBarUnplayedSegmentColor
        seekBar.pausedState.progressColor = PlayerStyleConstants.seekBarPlayedSegmentColor
        seekBar.pausedState.thumbColor = PlayerStyleConstants.seekBarPlayedSegmentColor
        seekBar.playingState.thumbImage = nil
        seekBar.pausedState.cornerRadius = 4
        seekBar.pausedState.isThumbVisible = true
        seekBar.pausedState.height = 8
        seekBar.pausedState.thumbSize = 14
    }

    mutating func applyFirstTimeSlideStyle() {
        firstTimeSlide.show = true
        firstTimeSlide.backgroundColor = UIColor(named: "first_time_slide_background_color") ?? .black
        
        // CTA appearance
        firstTimeSlide.cta.backgroundColor = UIColor(named: "first_time_slide_cta_button_color") ?? .blue
        firstTimeSlide.cta.textColor = UIColor(named: "first_time_slide_cta_button_text_color") ?? .white
        firstTimeSlide.cta.cornerRadius = 8
        firstTimeSlide.cta.title = "Tap to start"
        
        // Main title appearance
        firstTimeSlide.mainTitle.text = "Navigating Moments"
        firstTimeSlide.mainTitle.textColor = UIColor(named: "first_time_slide_sub_title_color") ?? .white
        
        // Subtitle appearance
        firstTimeSlide.subtitle.text = "Browse moments content using these gestures"
        firstTimeSlide.subtitle.textColor = UIColor(named: "first_time_slide_sub_title_color") ?? .white
        
        // Instructions appearance
        // Next instruction
        firstTimeSlide.instructions.next.headerText.text = "Go to the next video"
        firstTimeSlide.instructions.next.headerText.textColor = UIColor(named: "first_time_slide_header_color") ?? .white
        firstTimeSlide.instructions.next.headerText.font = .systemFont(ofSize: PlayerStyleConstants.headerTextSize, weight: .regular)
        
        firstTimeSlide.instructions.next.descriptionText.text = "Swipe up"
        firstTimeSlide.instructions.next.descriptionText.textColor = UIColor(named: "first_time_slide_description_color") ?? .lightGray
        firstTimeSlide.instructions.next.descriptionText.font = .systemFont(ofSize: PlayerStyleConstants.descriptionTextSize, weight: .regular)
        
        // Previous instruction
        firstTimeSlide.instructions.previous.headerText.text = "Go to the previous video"
        firstTimeSlide.instructions.previous.headerText.textColor = UIColor(named: "first_time_slide_header_color") ?? .white
        firstTimeSlide.instructions.previous.headerText.font = .systemFont(ofSize: PlayerStyleConstants.headerTextSize, weight: .regular)
        
        firstTimeSlide.instructions.previous.descriptionText.text = "Swipe down"
        firstTimeSlide.instructions.previous.descriptionText.textColor = UIColor(named: "first_time_slide_description_color") ?? .lightGray
        firstTimeSlide.instructions.previous.descriptionText.font = .systemFont(ofSize: PlayerStyleConstants.descriptionTextSize, weight: .regular)
        
        // Pause instruction
        firstTimeSlide.instructions.pause.headerText.text = "Pause"
        firstTimeSlide.instructions.pause.headerText.textColor = UIColor(named: "first_time_slide_header_color") ?? .white
        firstTimeSlide.instructions.pause.headerText.font = .systemFont(ofSize: PlayerStyleConstants.headerTextSize, weight: .regular)
        
        firstTimeSlide.instructions.pause.descriptionText.text = "Tap on screen"
        firstTimeSlide.instructions.pause.descriptionText.textColor = UIColor(named: "first_time_slide_description_color") ?? .lightGray
        firstTimeSlide.instructions.pause.descriptionText.font = .systemFont(ofSize: PlayerStyleConstants.descriptionTextSize, weight: .regular)
        
        // Play instruction
        firstTimeSlide.instructions.play.headerText.text = "Play"
        firstTimeSlide.instructions.play.headerText.textColor = UIColor(named: "first_time_slide_header_color") ?? .white
        firstTimeSlide.instructions.play.headerText.font = .systemFont(ofSize: PlayerStyleConstants.headerTextSize, weight: .regular)
        
        firstTimeSlide.instructions.play.descriptionText.text = "Tap on screen"
        firstTimeSlide.instructions.play.descriptionText.textColor = UIColor(named: "first_time_slide_description_color") ?? .lightGray
        firstTimeSlide.instructions.play.descriptionText.font = .systemFont(ofSize: PlayerStyleConstants.descriptionTextSize, weight: .regular)
        
        firstTimeSlide.instructions.customs = [
            .init(
                headerText: .init(
                    text: "Custom instruction 1",
                    font: .systemFont(ofSize: PlayerStyleConstants.headerTextSize),
                    textColor: .black
                ),
                descriptionText: .init(
                    text: "Custom instruction 1 description",
                    font: .systemFont(ofSize: PlayerStyleConstants.descriptionTextSize),
                    textColor: .black
                ),
                icon: UIImage(named: "ic_rounded_close")?.withTintColor(.black),
                isVisible: true
            ),
            .init(
                headerText: .init(
                    text: "Custom instruction 2",
                    font: .systemFont(ofSize: PlayerStyleConstants.headerTextSize),
                    textColor: .blue
                ),
                descriptionText: .init(
                    text: "Custom instruction 2 description",
                    font: .systemFont(ofSize: PlayerStyleConstants.descriptionTextSize),
                    textColor: .blue
                ),
                icon: UIImage(named: "ic_like_unselected"),
                isVisible: true
            ),
            .init(
                headerText: .init(
                    text: "Custom instruction 3",
                    font: .systemFont(ofSize: PlayerStyleConstants.headerTextSize),
                    textColor: .purple
                ),
                descriptionText: .init(
                    text: "Custom instruction 3 description",
                    font: .systemFont(ofSize: PlayerStyleConstants.descriptionTextSize),
                    textColor: .purple
                ),
                icon: UIImage(named: "ic_back_button")?.withTintColor(.black),
                isVisible: true
            )
        ]
    }
    
    mutating func applyFollowEntityStyle() {
        // Configure follow entity visibility and entity type
        followEntity.isVisible = true
        // First, try to find the player entity, then the team, and finally retrieve the first entity from the backend response.
        followEntity.entityType = .player(fallbackType: .team(fallbackType: .firstAvailable))
        
        // Configure follow state (when entity is followed)
        let followColor = UIColor(hex: "00B27C") ?? .green
        followEntity.followState.avatar.borderColor = followColor
        followEntity.followState.chip.backgroundColor = followColor
        followEntity.followState.chip.iconColor = .black
        
        // Configure unfollow state (when entity is not followed)
        followEntity.unfollowState.avatar.borderColor = .white
        followEntity.unfollowState.chip.backgroundColor = .white
        followEntity.unfollowState.chip.iconColor = .black
        followEntity.unfollowState.chip.contentSource = .text
    }
}
