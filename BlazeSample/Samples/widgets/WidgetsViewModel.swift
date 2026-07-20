//
//  WidgetsViewModel.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 17/06/2025.
//

import Foundation
import Combine
import BlazeSDK

/// The data source examples available in the "Edit data source" bottom sheet.
/// Each option maps to a different `BlazeDataSourceType` - see `WidgetDataState.toDataSource()`.
enum DataSourceExample: String, CaseIterable {
    case labels = "Labels"
    case ids = "IDs"
    case complexLabels = "Complex labels expression"
    case composite = "Composite"

    var description: String {
        switch self {
        case .labels: return "Content tagged with the widget's default label"
        case .ids: return "Two specific content items fetched by their IDs"
        case .complexLabels: return "A nested label expression with a labels priority"
        case .composite: return "Merges an empty optional source with a mandatory label source, deduplicated"
        }
    }
}

struct WidgetDataState: Equatable {
    var selectedExample: DataSourceExample = .labels
    /// The widget's main label, e.g. its stories / moments / videos default label.
    let labelName: String
    /// Sample content IDs (of the same content type as this widget) used by the "IDs" example.
    let sampleIds: [String]
    var orderType: BlazeOrderType

    /// A label that intentionally matches no content, used by the "Composite" example
    /// to demonstrate how a non-mandatory source that returns nothing is skipped.
    static let noContentLabel = "fake_label_with_no_content"

    /// Builds the `BlazeDataSourceType` for the selected example.
    /// Note: `orderType` is only relevant for the Labels and IDs examples.
    func toDataSource() -> BlazeDataSourceType {
        switch selectedExample {
        case .labels:
            // Content tagged with a single label.
            // See https://dev.wsc-sports.com/docs/ios-blazedatasourcetype
            return .labels(
                .singleLabel(labelName),
                orderType: orderType
            )

        case .ids:
            // Specific content items fetched by their IDs.
            return .ids(
                sampleIds,
                orderType: orderType
            )

        case .complexLabels:
            // A nested label expression combined with a labels priority.
            return .labels(
                complexLabelExpression,
                labelsPriority: simpleLabelsPriority
            )

        case .composite:
            // Combines multiple data sources into a single deduplicated feed.
            // See https://dev.wsc-sports.com/docs/ios-blazecompositedatasourcetype
            return .composite(dataSources: [optionalEmptySourceEntry, mandatoryLabelSourceEntry])
        }
    }

    // Builds "<labelName> OR (B AND C) OR D":
    // content matches if it has the main label, OR both B and C, OR D.
    // atLeastOneOf = logical OR, mustInclude = logical AND - they nest to form complex expressions.
    // The main label is a top-level OR operand, so content tagged with it is returned on its own -
    // that keeps the widget populated even though the sample B/C/D labels match nothing.
    private var complexLabelExpression: BlazeWidgetLabel {
        .atLeastOneOf(
            .singleLabel(labelName),
            .mustInclude("B", "C"),
            .singleLabel("D")
        )
    }

    // Orders the results by label priority: items labeled B come first, then C, then D.
    private var simpleLabelsPriority: [BlazeWidgetLabel] {
        [
            .singleLabel("B"),
            .singleLabel("C"),
            .singleLabel("D")
        ]
    }

    // An entry pointing at a label with no matching content. It is not mandatory, so when the
    // SDK fetches all entries in parallel and merges them (in declaration order, deduplicated
    // by item ID), this entry contributes nothing and is skipped silently.
    private var optionalEmptySourceEntry: BlazeCompositeDataSourceEntry {
        BlazeCompositeDataSourceEntry(
            dataSource: .labels(.singleLabel(Self.noContentLabel)),
            config: BlazeCompositeDataSourceConfig(isMandatory: false)
        )
    }

    // An entry pointing at the widget's real label. It is mandatory, so if this entry's fetch
    // fails, the whole composite fetch fails - regardless of whether other entries succeeded.
    private var mandatoryLabelSourceEntry: BlazeCompositeDataSourceEntry {
        BlazeCompositeDataSourceEntry(
            dataSource: .labels(.singleLabel(labelName)),
            config: BlazeCompositeDataSourceConfig(isMandatory: true)
        )
    }
}

enum WidgetScreenType: String {
    case storiesGrid
    case storiesRow
    case momentsRow
    case momentsGrid
    case videosRow
    case videosGrid
    case liveVideoRow
    case mixed
    case methodsDelegates
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
        case .liveVideoRow:
            return ConfigManager.videosLiveRowLabel
        case .mixed:
            return ""
        case .methodsDelegates:
            return ConfigManager.storiesRowLabel
        }
    }

    // Sample content IDs (matching this widget's content type) used by the "IDs" example.
    var sampleContentIds: [String] {
        switch self {
        case .storiesGrid, .storiesRow, .methodsDelegates:
            return ["65631c3f182ca9d8338f6ba4", "65631c2f182ca9d8338f6b99"]
        case .momentsRow, .momentsGrid:
            return ["6849439ea26bafd24a1f9ea6", "68494398a26bafd24a1f9ea1"]
        case .videosRow, .videosGrid:
            return ["684941b4a26bafd24a1f9e8f"]
        case .mixed:
            return []
        case .liveVideoRow:
            return []
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
        let layout = BlazeWidgetLayout.Presets.MomentsWidget.Grid.twoColumnsVerticalRectangles
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

    var liveVideoRowBaseLayout: BlazeWidgetLayout {
        var layout = BlazeWidgetLayout.Presets.VideosWidget.Row.horizontalRectangles
        layout.maxDisplayItemsCount = nil
        layout.widgetItemStyle.statusIndicator.isVisible = true
        layout.widgetItemStyle.statusIndicator.unreadState.backgroundColor = .init(named: "wsc_accent")!
        layout.widgetItemStyle.statusIndicator.unreadState.textStyle.textColor = .black
        return layout
    }

    // Requests stream content, across all stream states, so the Live Video
    // widget's demo data always has live/upcoming/ended items to show.
    var liveVideoFilterParams: BlazeVideosFilterParams {
        BlazeVideosFilterParams(contentTypes: [.stream], streamStates: [.live, .upcoming, .ended])
    }

    init(widgetType: WidgetScreenType = .storiesGrid) {
        self.currentWidgetType = widgetType
        self.widgetDataState = .init(
            labelName: currentWidgetType.dataSourceLabel,
            sampleIds: currentWidgetType.sampleContentIds,
            orderType: .manual
        )
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
        case .liveVideoRow:
            return liveVideoRowBaseLayout
        case .mixed:
            return videosGirdBaseLayout
        case .methodsDelegates:
            return storiesRowBaseLayout
        }
    }
}
