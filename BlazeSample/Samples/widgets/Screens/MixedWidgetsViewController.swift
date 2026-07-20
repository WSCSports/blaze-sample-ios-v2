//
//  MixedWidgetsViewController.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 23/06/2025.
//

import UIKit
import BlazeSDK

///
/// MixedWidgetsViewController is a View that displays a mix feed of Blaze widgets:
/// Stories-row, Moments-row, Live-video-row, Videos-row, and Stories-grid.
/// It manages reload widgets data with pull-to-refresh.
///

class MixedWidgetsViewController: UIViewController {
    
    private let contentView = MixedWidgetsView()
    private let viewModel = WidgetsViewModel(widgetType: .mixed)
    
    private var storiesRowWidgetView: BlazeStoriesWidgetRowView?
    private var storiesGridWidgetView: BlazeStoriesWidgetGridView?
    private var momentsRowWidgetView: BlazeMomentsWidgetRowView?
    private var videosRowWidgetView: BlazeVideosWidgetRowView?
    private var liveVideoRowWidgetView: BlazeVideosWidgetRowView?
    private var momentsTabsContainer: BlazeMomentsPlayerContainerTabs?

    override func loadView() {
        self.view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        initWidgets()
       
        contentView.refreshControl.addTarget(self, action: #selector(pullToRefreshTriggered), for: .valueChanged)
       
        viewModel.onRefreshCompleted = { [weak self] in
            self?.contentView.refreshControl.endRefreshing()
        }
    }
    
    func initWidgets() {
        initStoriesRowWidget()
        initMomentsTabsRowWidget()
        initLiveVideoRowWidget()
        initVideosRowWidget()
        initStoriesGridWidget()
    }
    
    func initStoriesRowWidget() {
        let widgetLayout = viewModel.storiesRowBaseLayout
        
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(ConfigManager.storiesRowLabel)
        )
        
        let widget = BlazeStoriesWidgetRowView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = "mixed-widgets-stories-row-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        self.storiesRowWidgetView = widget

        let section = WidgetSectionView.init(height: 160, title: "Stories row widget")
        widget.embedInView(section.containerView)
        widget.reloadData(progressType: .skeleton)
        contentView.stackView.addArrangedSubview(section)
    }
    
    func initStoriesGridWidget() {
        let widgetLayout = viewModel.storiesGridBaseLayout
        
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(ConfigManager.storiesGridLabel)
        )
        
        let widget = BlazeStoriesWidgetGridView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = "mixed-widgets-stories-grid-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        widget.isEmbededInScrollView = true
        self.storiesGridWidgetView = widget
        
        let section = WidgetSectionView.init(title: "Stories grid widget")
        widget.embedInView(section.containerView)
        widget.reloadData(progressType: .skeleton)
        contentView.stackView.addArrangedSubview(section)
    }

    func initMomentsTabsRowWidget() {
        let tabs: [BlazeMomentsContainerTabItem] = [
            BlazeMomentsContainerTabItem(
                containerId: "moments-container-trending",
                title: "Trending",
                dataSource: .labels(.singleLabel(ConfigManager.momentContainerLabel1))
            ),
            BlazeMomentsContainerTabItem(
                containerId: "moments-container-for-you",
                title: "For You",
                dataSource: .labels(.singleLabel(ConfigManager.momentContainerLabel2))
            )
        ]

        let tabsContainer = BlazeMomentsPlayerContainerTabs(
            tabs: tabs,
            tabsStyle: .base(),
            containerTabsDelegate: nil,
            containerSourceId: "mixed-widgets-moments-tabs-id"
        )
        momentsTabsContainer = tabsContainer

        let widget = BlazeMomentsWidgetRowView(layout: viewModel.momentsRowBaseLayout, tabsContainer: tabsContainer)
        widget.widgetIdentifier = "mixed-widgets-moments-tabs-row-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        self.momentsRowWidgetView = widget

        let section = WidgetSectionView(height: 300, title: "Moments Tabs Row widget")
        widget.embedInView(section.containerView)
        widget.reloadData(progressType: .skeleton)
        contentView.stackView.addArrangedSubview(section)
    }
    
    func initLiveVideoRowWidget() {
        // Shown here with the SDK's default (uncustomized) preset - see "Live video row"
        // under Browse Widgets for a version with status indicator customization.
        let widgetLayout = viewModel.liveVideoRowBaseLayout

        // advancedOrderType takes priority over orderType, surfacing live streams ahead of
        // upcoming/ended/VOD content regardless of the base order type.
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(ConfigManager.videosLiveRowLabel),
            advancedOrderType: .liveFirst
        )

        let widget = BlazeVideosWidgetRowView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = "mixed-widgets-live-video-row-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.videosFilterParams = viewModel.liveVideoFilterParams
        self.liveVideoRowWidgetView = widget

        let section = WidgetSectionView.init(height: 230, title: "Live video row widget")
        widget.embedInView(section.containerView)
        widget.reloadData(progressType: .skeleton)
        contentView.stackView.addArrangedSubview(section)
    }

    func initVideosRowWidget() {
        let widgetLayout = viewModel.videosRowBaseSingleItemLayout
        
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(ConfigManager.videosRowLabel)
        )
        
        let widget = BlazeVideosWidgetRowView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = "mixed-widgets-videos-row-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        self.videosRowWidgetView = widget
        
        let section = WidgetSectionView.init(height: 230, title: "Videos row widget")
        widget.embedInView(section.containerView)
        widget.reloadData(progressType: .skeleton)
        contentView.stackView.addArrangedSubview(section)
    }

    @objc private func pullToRefreshTriggered() {
        [momentsRowWidgetView, storiesGridWidgetView, storiesRowWidgetView, videosRowWidgetView, liveVideoRowWidgetView]
            .forEach { $0?.reloadData(progressType: .skeleton) }

        // Example: use the tabs container when the player is open to navigate back to the first tab on refresh.
        // momentsTabsContainer is non-nil only after initMomentsTabsRowWidget() is called.
        Logger.shared.log("momentsTabsContainer active: \(momentsTabsContainer != nil)")
        momentsTabsContainer?.selectTab(at: 0, animated: true)
    }
}
