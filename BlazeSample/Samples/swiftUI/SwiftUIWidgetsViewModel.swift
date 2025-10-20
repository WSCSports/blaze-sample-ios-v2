//
//  SwiftUIWidgetsViewModel.swift
//  SwiftUIWidgetsViewModel
//
//  Created by Max Lukashevich on 04/07/2025.
//

import BlazeSDK
import SwiftUI

final class SwiftUIWidgetsViewModel: ObservableObject {
    
    @Published var storiesRowViewModel: BlazeSwiftUIStoriesWidgetViewModel!
    @Published var storiesGridViewModel: BlazeSwiftUIStoriesWidgetViewModel!
    @Published var momentsRowViewModel: BlazeSwiftUIMomentsWidgetViewModel!
    @Published var momentsPlayerContainer: BlazeMomentsPlayerContainer!
    @Published var momentsPlayerContainerTabs: BlazeMomentsPlayerContainerTabs!

    private lazy var widgetDelegate = WidgetsDelegate.create(identifier: "SwiftUI")
    private lazy var containerDelegate = createMomentContainerDelegate()
    
    private lazy var storiesRowDataSourceType: BlazeDataSourceType = {
        .labels(.singleLabel(ConfigManager.storiesRowLabel))
    }()
    
    private lazy var momentsRowDataSourceType: BlazeDataSourceType = {
        .labels(.singleLabel(ConfigManager.momentsRowLabel))
    }()
    
    private lazy var storiesGridDataSourceType: BlazeDataSourceType = {
        .labels(.singleLabel(ConfigManager.storiesGridLabel), maxItems: 16)
    }()
        
    init () {
        setupWidgets()
        setupMomentsContainer()
        setupMomentsTabsContainer()
    }
        
    private func setupWidgets() {
        self.storiesRowViewModel = BlazeSwiftUIStoriesWidgetViewModel(
            widgetConfiguration: BlazeSwiftUIWidgetConfiguration(
                layout: .Presets.StoriesWidget.Row.circles,
                dataSourceType: storiesRowDataSourceType
            ),
            delegate: widgetDelegate,
            adsConfigType: .none // Set No ads for widget
        )
        
        self.momentsRowViewModel = BlazeSwiftUIMomentsWidgetViewModel(
            widgetConfiguration: .init(
                layout: .Presets.MomentsWidget.Row.verticalAnimatedThumbnailsRectangles,
                dataSourceType: momentsRowDataSourceType
            ),
            delegate: widgetDelegate,
            adsConfigType: .none // Set No ads for widget
        )
        
        self.storiesGridViewModel = BlazeSwiftUIStoriesWidgetViewModel(
            widgetConfiguration: .init(
                layout: .Presets.StoriesWidget.Grid.twoColumnsVerticalRectangles,
                dataSourceType: storiesGridDataSourceType,
                isEmbededInScrollView: true
            ),
            delegate: widgetDelegate,
            adsConfigType: .none // Set No ads for widget
        )
    }
    
    private func setupMomentsContainer() {
        var momentsPlayerStyle = BlazeMomentsPlayerStyle.base()
        momentsPlayerStyle.buttons.exit.isVisible = false
        
        momentsPlayerContainer = BlazeMomentsPlayerContainer(
            dataSourceType: .labels(
                .singleLabel(
                    ConfigManager.momentsRowLabel
                )
            ),
            shouldOrderMomentsByReadStatus: true,
            containerDelegate: containerDelegate,
            cachePolicyLevel: .Default,
            style: momentsPlayerStyle,
            adsConfigType: .none // Set No ads for container
        )
    }
    
    private func setupMomentsTabsContainer() {
        
        let tabs = [
            BlazeMomentsContainerTabItem.withDifferentIcons(
                containerId: "swiftui-moments-container-trending",
                title: "Trending",
                dataSource: .labels(.singleLabel(ConfigManager.momentContainerLabel1)),
                selectedIcon: UIImage(named: "tabs_trending_icon_selected")!,
                unselectedIcon: UIImage(named: "tabs_trending_icon")!,
                momentsAdsConfigType: .none // Set No ads for container
            ),
            BlazeMomentsContainerTabItem.withDifferentIcons(
                containerId: "swiftui-moments-container-for-you",
                title: "For You",
                dataSource: .labels(.singleLabel(ConfigManager.momentContainerLabel2)),
                selectedIcon: UIImage(named: "tabs_for_you_icon_selected")!,
                unselectedIcon: UIImage(named: "tabs_for_you_icon")!,
                momentsAdsConfigType: .none // Set No ads for container
            )
        ]
        
        momentsPlayerContainerTabs = BlazeMomentsPlayerContainerTabs(
            tabs: tabs,
            playerStyle: BlazeMomentsPlayerStyle.base(),
            tabsStyle: BlazePlayerTabsStyle.base(),
            containerTabsDelegate: createMomentsContainerTabsDelegate(),
            containerSourceId: "swiftui-moments-container-tabs"
        )
        
        // Prepare all tabs for faster loading
        momentsPlayerContainerTabs?.prepareAllTabs()
    }
    
    func reloadData(progressType: BlazeProgressType) {
        storiesRowViewModel.reloadData(progressType: progressType)
        momentsRowViewModel.reloadData(progressType: progressType)
        storiesGridViewModel.reloadData(progressType: progressType)
    }
}

extension SwiftUIWidgetsViewModel {
    private func createMomentContainerDelegate() -> BlazePlayerContainerDelegate {
        BlazePlayerContainerDelegate { params in
            Logger.shared.log("Moments Container - onDataLoadStarted", object: params)
        } onDataLoadComplete: { params in
            Logger.shared.log("Moments Container - onDataLoadComplete", object: params)
        } onPlayerDidAppear: { params in
            Logger.shared.log("Moments Container - onPlayerDidAppear", object: params)
        } onPlayerDidDismiss: { params in
            Logger.shared.log("Moments Container - onPlayerDidDismiss", object: params)
        } onPlayerEventTriggered: { params in
            Logger.shared.log("Moments Container - onPlayerEventTriggered", object: params)
        } onTriggerCustomActionButton: { params in
            Logger.shared.log("Moments Container - onTriggerCustomActionButton", object: params)
        }
    }
    
    private func createMomentsContainerTabsDelegate() -> BlazePlayerContainerTabsDelegate {
        BlazePlayerContainerTabsDelegate { params in
            Logger.shared.log("Moments Container Tabs - onDataLoadStarted", object: params)
        } onDataLoadComplete: { params in
            Logger.shared.log("Moments Container Tabs - onDataLoadComplete", object: params)
        } onPlayerDidAppear: { params in
            Logger.shared.log("Moments Container Tabs - onPlayerDidAppear", object: params)
        } onPlayerDidDismiss: { params in
            Logger.shared.log("Moments Container Tabs - onPlayerDidDismiss", object: params)
        } onTriggerCTA: { params in
            Logger.shared.log("Moments Container Tabs - onTriggerCTA", object: params)
            return false
        } onPlayerEventTriggered: { params in
            Logger.shared.log("Moments Container Tabs - onPlayerEventTriggered", object: params)
        } onTriggerCustomActionButton: { params in
            Logger.shared.log("Moments Container Tabs - onTriggerCustomActionButton", object: params)
        } onTabSelected: { params in
            Logger.shared.log("Moments Container Tabs - onTabSelected", object: params)
        }
    }
}
