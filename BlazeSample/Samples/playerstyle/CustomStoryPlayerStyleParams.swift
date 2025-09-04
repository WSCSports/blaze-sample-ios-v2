//
//  CustomStoryPlayerStyleParams.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 02/07/2025.
//

import UIKit
import BlazeSDK

struct StoryPlayerStyleConstants {
    static let headerTextSize: CGFloat = 22
    static let descriptionTextSize: CGFloat = 16
    static let progressBarColor = UIColor(hex: "FF6B35") ?? .orange
    static let backgroundColor = UIColor(hex: "181820") ?? .black
}

extension BlazeStoryPlayerStyle {
    
    static func customStoryPlayerStyle() -> BlazeStoryPlayerStyle {
        var style = BlazeStoryPlayerStyle.base()
        
        let bgColor = UIColor(hex: "181820") ?? .black
        style.backgroundColor = bgColor
        
        // Story title appearance
        style.title.textColor = .white
        style.title.font = .systemFont(ofSize: 12)
        
         // Story last update appearance
         style.lastUpdate.textColor = .white
         style.lastUpdate.font = .systemFont(ofSize: 12)
        
        // CTA button appearance
        style.cta.cornerRadius = 20
        style.cta.font = .systemFont(ofSize: 18)
        
        // Player header gradient appearance
        style.headerGradient.isVisible = true
        style.headerGradient.startColor = bgColor
        style.headerGradient.endColor = .clear
        
        // Player progress bar appearance
        style.progressBar.backgroundColor = .gray
        style.progressBar.progressColor = .white
        
        // Apply custom buttons style
        style.buttons.applyCustomStoryButtonsStyle()
        
        // Apply custom chips style
        style.chips.applyCustomStoryChipsStyle()
        
        // Apply custom first time slide style
        style.firstTimeSlide.applyCustomStoryFirstTimeSlideStyle()
        
        return style
    }
}

extension BlazeStoryPlayerButtonsStyle {
    
    mutating func applyCustomStoryButtonsStyle() {
        // Exit button appearance
        exit.isVisible = true
        exit.color = .white
        exit.width = 48
        exit.height = 48
        exit.isVisibleForAds = false
        
        // Button images state appearance
        if let exitImage = UIImage(named: "ic_rounded_close") {
            exit.customImage = .init(default: exitImage, selected: nil)
        }

        // Share button appearance
        share.isVisible = true
        share.color = .white
        share.width = 48
        share.height = 48
        share.isVisibleForAds = true
        
        // Button images state appearance
        if let shareImage = UIImage(named: "ic_share") {
            share.customImage = .init(default: shareImage, selected: shareImage)
        }

        // Mute button appearance
        mute.isVisible = true
        mute.color = .white
        mute.width = 48
        mute.height = 48
        mute.isVisibleForAds = true
        
        // Button images state appearance
        if let muteOffImage = UIImage(named: "ic_sound_off"), let muteOnImage = UIImage(named: "ic_sound_on") {
            mute.customImage = .init(default: muteOnImage, selected: muteOffImage)
        }
        
        // Captions button appearance
        captions.isVisible = true
        
        // Custom action button
        var custom1 = BlazeStoryPlayerCustomActionButton(
            customParams: BlazePlayerCustomActionButtonParams(
                id: "custom1",
                appMetadata: [:],
                name: "My custom 1"
            )
        )
        if let customButtonImage = UIImage(named: "ic_custom_player_button") {
            custom1.style.customImage = .init(default: customButtonImage, selected: customButtonImage)
        }
        custom1.style.customImage?.selected = nil

        // Set custom buttons
        setTopStackCustomActionButtons([custom1])
        
        // Story top stack button ordering
        setTopStackOrder([
            .exit,
            .mute,
            .customAction(id: custom1.customParams.id),
            .share,
            .captions
        ])
    }
}

extension BlazeStoryPlayerChipsStyle {
    
    mutating func applyCustomStoryChipsStyle() {
        // Live chip appearance
        live.titlePadding.leading = 12
        live.titlePadding.top = 2
        live.titlePadding.trailing = 12
        live.titlePadding.bottom = 2
        live.text = "LIVE"
        live.textColor = .white
        live.backgroundColor = PlayerStyleConstants.liveChipBgColor
        
        // Ad chip appearance
        ad.titlePadding.leading = 12
        ad.titlePadding.top = 2
        ad.titlePadding.trailing = 12
        ad.titlePadding.bottom = 2
        ad.text = "AD"
        ad.textColor = .white
        ad.backgroundColor = PlayerStyleConstants.adChipBgColor
    }
}

extension BlazeStoryPlayerFirstTimeSlideStyle {
    
    mutating func applyCustomStoryFirstTimeSlideStyle() {
        show = true
        backgroundColor = UIColor(named: "first_time_slide_background_color") ?? .black
        
        // CTA appearance
        cta.backgroundColor = UIColor(named: "first_time_slide_cta_button_color") ?? .blue
        cta.textColor = UIColor(named: "first_time_slide_cta_button_text_color") ?? .white
        cta.cornerRadius = 8
        cta.title = "Tap to start"
        
        // Main title appearance
        mainTitle.text = "Navigating Stories"
        mainTitle.textColor = UIColor(named: "first_time_slide_sub_title_color") ?? .white
        
        // Subtitle appearance
        subtitle.text = "Browse story content using these gestures"
        subtitle.textColor = UIColor(named: "first_time_slide_sub_title_color") ?? .white
        
        // Instructions appearance
        instructions.forward.headerText.text = "Go forward"
        instructions.forward.headerText.textColor = UIColor(named: "first_time_slide_header_color") ?? .white
        instructions.forward.headerText.font = .systemFont(ofSize: PlayerStyleConstants.headerTextSize)
        instructions.forward.descriptionText.text = "Tap the screen"
        instructions.forward.descriptionText.textColor = UIColor(named: "first_time_slide_description_color") ?? .gray
        instructions.forward.descriptionText.font = .systemFont(ofSize: PlayerStyleConstants.descriptionTextSize)
        
        instructions.backward.headerText.text = "Go back"
        instructions.backward.headerText.textColor = UIColor(named: "first_time_slide_header_color") ?? .white
        instructions.backward.headerText.font = .systemFont(ofSize: PlayerStyleConstants.headerTextSize)
        instructions.backward.descriptionText.text = "Tap the left edge"
        instructions.backward.descriptionText.textColor = UIColor(named: "first_time_slide_description_color") ?? .gray
        instructions.backward.descriptionText.font = .systemFont(ofSize: PlayerStyleConstants.descriptionTextSize)
        
        instructions.pause.headerText.text = "Pause"
        instructions.pause.headerText.textColor = UIColor(named: "first_time_slide_header_color") ?? .white
        instructions.pause.headerText.font = .systemFont(ofSize: PlayerStyleConstants.headerTextSize)
        instructions.pause.descriptionText.text = "Press and hold the screen"
        instructions.pause.descriptionText.textColor = UIColor(named: "first_time_slide_description_color") ?? .gray
        instructions.pause.descriptionText.font = .systemFont(ofSize: PlayerStyleConstants.descriptionTextSize)
        
        instructions.transition.headerText.text = "Move between stories"
        instructions.transition.headerText.textColor = UIColor(named: "first_time_slide_header_color") ?? .white
        instructions.transition.headerText.font = .systemFont(ofSize: PlayerStyleConstants.headerTextSize)
        instructions.transition.descriptionText.text = "Swipe left or right"
        instructions.transition.descriptionText.textColor = UIColor(named: "first_time_slide_description_color") ?? .gray
        instructions.transition.descriptionText.font = .systemFont(ofSize: PlayerStyleConstants.descriptionTextSize)
        
        // Custom instructions
        instructions.customs = [
            .init(
                headerText: .init(
                    text: "Custom instruction 1",
                    font: .systemFont(ofSize: StoryPlayerStyleConstants.headerTextSize),
                    textColor: .black
                ),
                descriptionText: .init(
                    text: "Custom instruction 1 description",
                    font: .systemFont(ofSize: StoryPlayerStyleConstants.descriptionTextSize),
                    textColor: .black
                ),
                icon: UIImage(named: "ic_rounded_close")?.withTintColor(.black),
                isVisible: true
            ),
            .init(
                headerText: .init(
                    text: "Custom instruction 2",
                    font: .systemFont(ofSize: StoryPlayerStyleConstants.headerTextSize),
                    textColor: .blue
                ),
                descriptionText: .init(
                    text: "Custom instruction 2 description",
                    font: .systemFont(ofSize: StoryPlayerStyleConstants.descriptionTextSize),
                    textColor: .blue
                ),
                icon: UIImage(named: "ic_like_unselected"),
                isVisible: true
            ),
            .init(
                headerText: .init(
                    text: "Custom instruction 3",
                    font: .systemFont(ofSize: StoryPlayerStyleConstants.headerTextSize),
                    textColor: .purple
                ),
                descriptionText: .init(
                    text: "Custom instruction 3 description",
                    font: .systemFont(ofSize: StoryPlayerStyleConstants.descriptionTextSize),
                    textColor: .purple
                ),
                icon: UIImage(named: "ic_back_button")?.withTintColor(.black),
                isVisible: true
            )
        ]
    }
}
