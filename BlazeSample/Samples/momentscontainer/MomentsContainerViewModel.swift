//
//  MomentsContainerViewModel.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 24/06/2025.
//

import Foundation
import Combine
import BlazeSDK
import UIKit

///
/// This ViewModel is used to demonstrate how to use BlazeMomentsPlayerContainer.
/// It contains two BlazeMomentsPlayerStyle instances and demonstrates the usage of
/// dynamic moment appending functionality using player event handling.
/// For more information and player container customizations, see https://dev.wsc-sports.com/docs/ios-moments-player-customizations#/.
///

struct MomentsContainerValues {
    static let momentsLabel = ConfigManager.momentsGridLabel
    static let instantMomentsContainerId = "instant-moments-container-unique-id"
    static let lazyMomentsContainerId = "lazy-moments-container-unique-id"
    static let momentsContainerId = "Moments-container-unique-id"
    static let momentsContainerTabLabel1 = ConfigManager.momentContainerLabel1
    static let momentsContainerTabLabel2 = ConfigManager.momentContainerLabel2
}

final class MomentsContainerViewModel {

    let onMomentsTabSelected = PassthroughSubject<Void, Never>()
    
    /// Flag to track whether new moments have already been appended to prevent multiple additions
    private var didAppendNewMoments = false
    
    lazy var tabs: [BlazeMomentsContainerTabItem] = {
        return [
            BlazeMomentsContainerTabItem.withDifferentIcons(
                containerId: "moments-container-trending",
                title: "Trending",
                dataSource: .labels(.singleLabel(MomentsContainerValues.momentsContainerTabLabel1)),
                selectedIcon: UIImage(named: "tabs_trending_icon_selected")!,
                unselectedIcon: UIImage(named: "tabs_trending_icon")!,
                momentsAdsConfigType: .firstAvailableAdsConfig
            ),
            BlazeMomentsContainerTabItem.withDifferentIcons(
                containerId: "moments-container-for-you",
                title: "For You",
                dataSource: .labels(.singleLabel(MomentsContainerValues.momentsContainerTabLabel2)),
                selectedIcon: UIImage(named: "tabs_for_you_icon_selected")!,
                unselectedIcon: UIImage(named: "tabs_for_you_icon")!,
                momentsAdsConfigType: .firstAvailableAdsConfig
            )
        ]
    }()
        
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

    lazy var momentsTabsContainer: BlazeMomentsPlayerContainerTabs = {
        return BlazeMomentsPlayerContainerTabs(
            tabs: tabs,
            playerStyle: momentsPlayerStyle,
            tabsStyle: BlazePlayerTabsStyle.base(),
            containerTabsDelegate: createMomentsContainerDelegate(),
            containerSourceId: MomentsContainerValues.momentsContainerId
        )
    }()

    func triggerMomentsTabSelected() {
        onMomentsTabSelected.send(())
    }
    
    /// Example of using player event handling for dynamic content loading
    /// Handles player events to determine when to append new moments dynamically
    /// This method is called when player events are triggered from the Blaze SDK
    func handlePlayerEvent(_ event: BlazePlayerEvent, sourceId: String?) {
        if shouldAppendMoreMoments(event) {
            guard let sourceId = sourceId else { return }
            didAppendNewMoments = true
            appendNewMoments(sourceId: sourceId)
        }
    }
    
    /// Determines if more moments should be appended based on the current playback progress
    /// Returns true when user reaches 80% of the total moments and new moments haven't been added yet
    private func shouldAppendMoreMoments(_ event: BlazePlayerEvent) -> Bool {
        guard case let .onMomentStart(params) = event else { return false }
        
        let momentIndex = params.momentIndex
        let totalCount = params.totalMomentsCount
        let threshold = 0.8 // 80% threshold for triggering new moments
        
        return !didAppendNewMoments && Double(momentIndex) >= (Double(totalCount) * threshold)
    }
    
    private func appendNewMoments(sourceId: String) {
        Blaze.shared.appendMomentsToPlayer(
            sourceId: sourceId,
            dataSourceType: .labels(.singleLabel(MomentsContainerValues.momentsContainerTabLabel2))
        )
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
            },
            onPlayerEventTriggered: { [weak self] params in
                self?.handlePlayerEvent(params.event, sourceId: params.sourceId)
            }
        )
    }
}

extension MomentsContainerViewModel {
    /// Creates a delegate for handling tabbed moments container events
    /// Includes player event handling for dynamic moment appending across tabs
    func createMomentsContainerDelegate() -> BlazePlayerContainerTabsDelegate {
        return BlazePlayerContainerTabsDelegate { params in
            Logger.shared.log("ContainerTabsDelegate onDataLoadStarted", object: params)
        } onDataLoadComplete: { params in
            Logger.shared.log("ContainerTabsDelegate onDataLoadComplete", object: params)
        } onPlayerDidAppear: { params in
            Logger.shared.log("ContainerTabsDelegate onPlayerDidAppear", object: params)
        } onPlayerDidDismiss: { params in
            Logger.shared.log("ContainerTabsDelegate onPlayerDidDismiss", object: params)
        } onTriggerCTA: { params in
            Logger.shared.log("ContainerTabsDelegate onTriggerCTA", object: params)
            return false
        } onPlayerEventTriggered: { [weak self] params in
            Logger.shared.log("ContainerTabsDelegate onPlayerEventTriggered", object: params)
            self?.handlePlayerEvent(params.event, sourceId: params.sourceId)
        } onTriggerCustomActionButton: { params in
            Logger.shared.log("ContainerTabsDelegate onTriggerCustomActionButton", object: params)
        } onTabSelected: { params in
            Logger.shared.log("ContainerTabsDelegate onTabSelected", object: params)
        }
    }
}

