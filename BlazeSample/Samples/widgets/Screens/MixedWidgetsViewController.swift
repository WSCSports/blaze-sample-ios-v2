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
/// Stories-row, Moments-row, and Stories-grid.
/// It manages reload widgets data with pull-to-refresh.
///

class MixedWidgetsViewController: UIViewController {
    
    private let contentView = MixedWidgetsView()
    private let viewModel = WidgetsViewModel(widgetType: .mixed)
    
    private var storiesRowWidgetView: BlazeStoriesWidgetRowView?
    private var storiesGridWidgetView: BlazeStoriesWidgetGridView?
    private var momentsRowWidgetView: BlazeMomentsWidgetRowView?
    private var videosRowWidgetView: BlazeVideosWidgetRowView?

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
        initMomentsRowWidget()
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

    func initMomentsRowWidget() {
        let widgetLayout = viewModel.momentsRowBaseLayout
        
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(ConfigManager.momentsRowLabel)
        )
        
        let widget = BlazeMomentsWidgetRowView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = "mixed-widgets-moments-row-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        self.momentsRowWidgetView = widget
        
        let section = WidgetSectionView.init(height: 300, title: "Moment row widget")
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
        [momentsRowWidgetView, storiesGridWidgetView, storiesRowWidgetView, videosRowWidgetView]
            .forEach { $0?.reloadData(progressType: .skeleton) }
    }
}
