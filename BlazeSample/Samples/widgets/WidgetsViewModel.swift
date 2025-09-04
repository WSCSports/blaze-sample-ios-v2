//
//  WidgetsViewModel.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 17/06/2025.
//

import Foundation
import Combine
import BlazeSDK

struct WidgetDataState: Equatable {
    let labelName: String
    let orderType: BlazeOrderType
}

enum WidgetScreenType: String {
    case storiesGrid
    case storiesRow
    case momentsRow
    case momentsGrid
    case videosRow
    case videosGrid
    case mixed
}

extension WidgetScreenType {
    var dataSourceLabel: String {
        switch self {
        case .storiesGrid:
            return ConfigManager.storiesGridLabel
        case .storiesRow:
            return ConfigManager.storiesRowLabel
        case .momentsRow:
            return ConfigManager.momentsRowLabel
        case .momentsGrid:
            return ConfigManager.momentsGridLabel
        case .videosRow:
            return ConfigManager.videosRowLabel
        case .videosGrid:
            return ConfigManager.videosGridLabel
        case .mixed:
            return ""
        }
    }
}

///
/// This ViewModel demonstrates how to use BlazeSDK widgets in your application.
/// It shows how to create and configure different types of widgets (Stories, Moments, Videos) 
/// with various layouts and data sources.
///

final class WidgetsViewModel {
    
    let currentWidgetType: WidgetScreenType
    lazy var widgetDelegate: BlazeWidgetDelegate = WidgetsDelegate.create(
        identifier: "Widgets",
        onDataLoadComplete: { [weak self] in
            self?.onRefreshCompleted?()
        }
    )

    @Published var styleState: WidgetLayoutStyleState
    @Published var widgetDataState: WidgetDataState
    
    var onRefreshCompleted: (() -> Void)?

    var storiesRowBaseLayout: BlazeWidgetLayout {
        BlazeWidgetLayout.Presets.StoriesWidget.Row.circles
    }
    
    var storiesGridBaseLayout: BlazeWidgetLayout {
        BlazeWidgetLayout.Presets.StoriesWidget.Grid.twoColumnsVerticalRectangles
    }
    
    var momentsRowBaseLayout: BlazeWidgetLayout {
        var layout = BlazeWidgetLayout.Presets.MomentsWidget.Row.verticalAnimatedThumbnailsRectangles
        layout.horizontalItemsSpacing = 0
        layout.widgetItemStyle.image.insets.top = 16
        layout.widgetItemStyle.image.insets.trailing = 8
        layout.widgetItemStyle.statusIndicator.isVisible = true
        layout.widgetItemStyle.statusIndicator.position.xPosition = .leadingToLeading(offset: 8)
        layout.widgetItemStyle.statusIndicator.position.yPosition = .topToTop(offset: 8)
        return layout
    }

    var momentsGirdBaseLayout: BlazeWidgetLayout {
        var layout = BlazeWidgetLayout.Presets.MomentsWidget.Grid.twoColumnsVerticalRectangles
        // Further customization for the grid layout if needed
        return layout
    }
    
    var videosRowBaseLayout: BlazeWidgetLayout {
        var layout = BlazeWidgetLayout.Presets.VideosWidget.Row.horizontalRectangles
        layout.horizontalItemsSpacing = 16
        return layout
    }
    
    var videosGirdBaseLayout: BlazeWidgetLayout {
        var layout = BlazeWidgetLayout.Presets.VideosWidget.Grid.twoColumnsHorizontalRectangles
        layout.horizontalItemsSpacing = 16
        layout.verticalItemsSpacing = 16
        return layout
    }
    
    var videosRowBaseSingleItemLayout: BlazeWidgetLayout {
        var layout = BlazeWidgetLayout.Presets.VideosWidget.Row.singleItemHorizontalRectangle
        layout.margins = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        return layout
    }

    init(widgetType: WidgetScreenType = .storiesGrid) {
        self.currentWidgetType = widgetType
        self.widgetDataState = .init(labelName: currentWidgetType.dataSourceLabel, orderType: .manual)
        self.styleState = WidgetLayoutStyleState()
    }
    
    func getWidgetLayoutBasePreset() -> BlazeWidgetLayout {
        switch currentWidgetType {
        case .storiesGrid:
            return storiesGridBaseLayout
        case .storiesRow:
            return storiesRowBaseLayout
        case .momentsRow:
            return momentsRowBaseLayout
        case .momentsGrid:
            return momentsGirdBaseLayout
        case .videosRow:
            return videosRowBaseLayout
        case .videosGrid:
            return videosGirdBaseLayout
        case .mixed:
            return videosGirdBaseLayout
        }
    }
}
