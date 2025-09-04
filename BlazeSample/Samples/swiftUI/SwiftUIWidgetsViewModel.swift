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
}
