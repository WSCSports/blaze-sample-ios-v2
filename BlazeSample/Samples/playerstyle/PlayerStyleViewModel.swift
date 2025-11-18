//
//  PlayerStyleViewModel.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 02/07/2025.
//

import Foundation
import Combine
import BlazeSDK

///
/// This ViewModel demonstrates how to use custom player styles for both Stories and Moments players.
/// It shows how to apply custom styling to BlazeStoryPlayer, BlazeMomentsPlayer and BlazeVideosPlayerStyle using widgets.
/// More information about Blaze players style customization can be found in the documentation:
/// https://dev.wsc-sports.com/docs/ios-blaze-story-player-style/
/// https://dev.wsc-sports.com/docs/ios-blaze-moments-player-style/
/// https://dev.wsc-sports.com/docs/ios-blazevideosplayerstyle/

final class PlayerStyleViewModel: ObservableObject {
    
    // MARK: - Constants
    struct Constants {
        static let storiesLabel = ConfigManager.storiesRowLabel
        static let momentsLabel = ConfigManager.momentsRowLabel
    }
    
    // MARK: - Follow Entities Manager
    
    var followEntitiesManager: BlazeFollowEntitiesManager {
        let manager = Blaze.shared.followEntitiesManager
        manager.delegate = self
        return manager
    }
    
    // MARK: - Widget Delegate
    lazy var widgetDelegate: BlazeWidgetDelegate = WidgetsDelegate.create(
        identifier: "PlayerStyle",
        onDataLoadComplete: { [weak self] in
            self?.onRefreshCompleted?()
        }
    )
    
    // MARK: - Widget Layouts
    var storiesWidgetLayout: BlazeWidgetLayout {
        BlazeWidgetLayout.Presets.StoriesWidget.Row.circles
    }
    
    var momentsWidgetLayout: BlazeWidgetLayout {
        var layout = BlazeWidgetLayout.Presets.MomentsWidget.Row.verticalAnimatedThumbnailsRectangles
        layout.horizontalItemsSpacing = 8
        layout.widgetItemStyle.image.insets.top = 8
        layout.widgetItemStyle.image.insets.trailing = 8
        return layout
    }
    
    var videosRowBaseSingleItemLayout: BlazeWidgetLayout {
        var layout = BlazeWidgetLayout.Presets.VideosWidget.Row.singleItemHorizontalRectangle
        layout.margins = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        return layout
    }
    
    // MARK: - Data Sources
    var storiesDataSource: BlazeDataSourceType {
        BlazeDataSourceType.labels(.singleLabel(Constants.storiesLabel))
    }
    
    var momentsDataSource: BlazeDataSourceType {
        BlazeDataSourceType.labels(.singleLabel(Constants.momentsLabel))
    }
    
    // MARK: - Custom Player Styles
    var customStoryPlayerStyle: BlazeStoryPlayerStyle {
        return BlazeStoryPlayerStyle.customStoryPlayerStyle()
    }
    
    var customMomentsPlayerStyle: BlazeMomentsPlayerStyle {
        return BlazeMomentsPlayerStyle.customMomentsPlayerStyle()
    }
    
    var customVideosPlayerStyle: BlazeVideosPlayerStyle {
        return BlazeVideosPlayerStyle.customVideosPlayerStyle()
    }
    
    // MARK: - Default Player Styles
    var defaultStoryPlayerStyle: BlazeStoryPlayerStyle {
        return BlazeStoryPlayerStyle.base()
    }
    
    var defaultMomentsPlayerStyle: BlazeMomentsPlayerStyle {
        return BlazeMomentsPlayerStyle.base()
    }
    
    var defaultVideosPlayerStyle: BlazeVideosPlayerStyle {
        return BlazeVideosPlayerStyle.base()
    }
    
    // MARK: - Refresh Control
    var onRefreshCompleted: (() -> Void)?
}

extension PlayerStyleViewModel: BlazeFollowEntitiesDelegate {
    func onFollowEntityClicked(_ params: BlazeSDK.BlazeFollowEntityClickedParams) {
        Logger.shared.log("BlazeFollowEntitiesDelegate: Place to sync entities with the backend/local storage.\n onFollowEntityClicked called: \(params)")
    }
}
