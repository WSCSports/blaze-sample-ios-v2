//
//  PlayerStyleViewController.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 02/07/2025.
//

import UIKit
import BlazeSDK

///
/// This ViewController demonstrates how to use Blaze widgets to display stories and moments with
/// different player styles, default style and custom style.
/// For more information, see:
/// https://dev.wsc-sports.com/docs/ios-story-player-customizations#/
/// https://dev.wsc-sports.com/docs/ios-moments-player-customizations#/
///

final class PlayerStyleViewController: UIViewController {
    
    
    // MARK: - Properties
    private let viewModel = PlayerStyleViewModel()
    
    private lazy var contentView: MixedWidgetsView = {
        let view = MixedWidgetsView()
        view.refreshControl.removeFromSuperview()
        return view
    }()

    // MARK: - Widget Views
    private var defaultStoriesRowWidgetView: BlazeStoriesWidgetRowView?
    private var customStoriesRowWidgetView: BlazeStoriesWidgetRowView?
    private var defaultMomentsRowWidgetView: BlazeMomentsWidgetRowView?
    private var customMomentsRowWidgetView: BlazeMomentsWidgetRowView?
    private var defaultVideosRowWidgetView: BlazeVideosWidgetRowView?
    private var customVideosRowWidgetView: BlazeVideosWidgetRowView?

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
    
    private func initWidgets() {
        initDefaultStoriesRowWidget()
        initCustomStoriesRowWidget()
        initDefaultMomentsRowWidget()
        initCustomMomentsRowWidget()
        initDefaultVideosRowWidget()
        initCustomVideosRowWidget()
    }
    
    // MARK: - Widget Initialization
    private func initDefaultStoriesRowWidget() {
        let widgetLayout = viewModel.storiesWidgetLayout
        
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(ConfigManager.storiesRowLabel)
        )
        
        let widget = BlazeStoriesWidgetRowView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = "default-stories-row-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        widget.storyPlayerStyle = viewModel.defaultStoryPlayerStyle
        self.defaultStoriesRowWidgetView = widget
        
        let section = WidgetSectionView(height: 160, title: "Default Stories Player Style")
        widget.embedInView(section.containerView)
        widget.reloadData(progressType: .skeleton)
        contentView.stackView.addArrangedSubview(section)
    }
    
    private func initCustomStoriesRowWidget() {
        let widgetLayout = viewModel.storiesWidgetLayout
        
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(ConfigManager.storiesRowLabel)
        )
        
        let widget = BlazeStoriesWidgetRowView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = "custom-stories-row-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        widget.storyPlayerStyle = viewModel.customStoryPlayerStyle
        self.customStoriesRowWidgetView = widget
        
        let section = WidgetSectionView(height: 160, title: "Custom Stories Player Style")
        widget.embedInView(section.containerView)
        widget.reloadData(progressType: .skeleton)
        contentView.stackView.addArrangedSubview(section)
    }
    
    private func initDefaultMomentsRowWidget() {
        let widgetLayout = viewModel.momentsWidgetLayout
        
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(ConfigManager.momentsRowLabel)
        )
        
        let widget = BlazeMomentsWidgetRowView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = "default-moments-row-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        widget.momentsPlayerStyle = viewModel.defaultMomentsPlayerStyle
        self.defaultMomentsRowWidgetView = widget
        
        let section = WidgetSectionView(height: 252, title: "Default Moments Player Style")
        widget.embedInView(section.containerView)
        widget.reloadData(progressType: .skeleton)
        contentView.stackView.addArrangedSubview(section)
    }
    
    private func initCustomMomentsRowWidget() {
        let widgetLayout = viewModel.momentsWidgetLayout
        
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(ConfigManager.momentsRowLabel)
        )
        
        let widget = BlazeMomentsWidgetRowView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = "custom-moments-row-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        widget.momentsPlayerStyle = viewModel.customMomentsPlayerStyle
        self.customMomentsRowWidgetView = widget
        
        let section = WidgetSectionView(height: 252, title: "Custom Moments Player Style")
        widget.embedInView(section.containerView)
        widget.reloadData(progressType: .skeleton)
        contentView.stackView.addArrangedSubview(section)
    }
    
    private func initDefaultVideosRowWidget() {
        let widgetLayout = viewModel.videosRowBaseSingleItemLayout
        
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(ConfigManager.videosRowLabel)
        )
        
        let widget = BlazeVideosWidgetRowView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = "default-videos-row-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        widget.videosPlayerStyle = viewModel.defaultVideosPlayerStyle

        let section = WidgetSectionView(height: 252, title: "Defaule Videos Player Style")
        widget.embedInView(section.containerView)
        widget.reloadData(progressType: .skeleton)
        contentView.stackView.addArrangedSubview(section)
        
        defaultVideosRowWidgetView = widget
    }
    
    private func initCustomVideosRowWidget() {
        let widgetLayout = viewModel.videosRowBaseSingleItemLayout
        
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(ConfigManager.videosRowLabel)
        )
        
        let widget = BlazeVideosWidgetRowView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = "custom-videos-row-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        widget.videosPlayerStyle = viewModel.customVideosPlayerStyle
        
        let section = WidgetSectionView(height: 252, title: "Custom Videos Player Style")
        widget.embedInView(section.containerView)
        widget.reloadData(progressType: .skeleton)
        contentView.stackView.addArrangedSubview(section)
        
        customVideosRowWidgetView = widget
    }
    
    // MARK: - Actions
    
    @objc private func pullToRefreshTriggered() {
        [
            defaultStoriesRowWidgetView,
            customStoriesRowWidgetView,
            defaultMomentsRowWidgetView,
            customMomentsRowWidgetView,
            defaultVideosRowWidgetView,
            customVideosRowWidgetView
        ]
            .forEach {
                $0?.reloadData(
                    progressType: .skeleton
                )
            }
    }
}
