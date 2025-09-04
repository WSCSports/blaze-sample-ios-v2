//
//  MomentsContainerViewModel.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 24/06/2025.
//

import Foundation
import Combine
import BlazeSDK

///
/// This ViewModel is used to demonstrate how to use BlazeMomentsPlayerContainer.
/// It contains two BlazeMomentsPlayerStyle instances.
/// For more information and player container customizations, see https://dev.wsc-sports.com/docs/ios-moments-player-customizations#/.
///

struct MomentsContainerValues {
    static let momentsLabel = ConfigManager.momentsGridLabel
    static let instantMomentsContainerId = "instant-moments-container-unique-id"
    static let lazyMomentsContainerId = "lazy-moments-container-unique-id"
}

final class MomentsContainerViewModel {

    let onMomentsTabSelected = PassthroughSubject<Void, Never>()
    
    var momentsPlayerStyle: BlazeMomentsPlayerStyle = {
        var style = BlazeMomentsPlayerStyle.base()
        style.playerDisplayMode = .resizeAspectFillCenterCrop
        style.firstTimeSlide.cta.backgroundColor = .init(named: "wsc_accent")!
        style.firstTimeSlide.cta.textColor = .black
        style.buttons.exit.isVisible = false
        style.buttons.exit.isVisibleForAds = false
        style.seekBar.playingState.cornerRadius = 0
        style.seekBar.pausedState.cornerRadius = 0
        style.seekBar.pausedState.isThumbVisible = false
        style.seekBar.bottomSpacing = 0
        style.seekBar.horizontalSpacing = 0
        style.cta.horizontalAlignment = .leading
        style.cta.layoutPositioning = .ctaNextToBottomButtonsBox
        style.cta.height = 32
        style.cta.cornerRadius = 16
        style.cta.font = .systemFont(ofSize: 14, weight: .medium)
        style.cta.icon = .init(named: "ic_play")!
        style.headingText.font = .systemFont(ofSize: 14, weight: .light)
        style.headingText.textColor = .white
        style.headingText.contentSource = .subtitle
        style.headingText.isVisible = true
        style.bodyText.font = .systemFont(ofSize: 16, weight: .bold)
        style.bodyText.textColor = .white
        style.bodyText.contentSource = .description
        style.bodyText.isVisible = true
        style.buttons.captions.isVisible = true
        return style
    }()

    func triggerMomentsTabSelected() {
        onMomentsTabSelected.send(())
    }
}

extension MomentsContainerViewModel {
    func createContainerDelegate() -> BlazePlayerContainerDelegate {
        return BlazePlayerContainerDelegate(
            onDataLoadStarted: { params in
                Logger.shared.log("onDataLoadStarted", object: params)
            },
            onDataLoadComplete: { params in
                Logger.shared.log("onDataLoadComplete", object: params)
            },
            onPlayerDidDismiss: { params in
                Logger.shared.log("onPlayerDidDismiss", object: params)
            },
            onTriggerCTA: { params in
                Logger.shared.log("onTriggerCTA", object: params)
                return false
            }
        )
    }
}
