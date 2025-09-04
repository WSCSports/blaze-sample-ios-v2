//
//  AdsViewController.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 04/07/2025.
//

import UIKit
import BlazeSDK

///
/// This ViewController demonstrates how to enable Blaze SDK ads in your app.
/// For more information on the ads configuration, refer to https://dev.wsc-sports.com/docs/ios-ads#/
///

class AdsViewController: UIViewController {
    
    private let viewModel = AdsViewModel()
    
    private lazy var contentView: MixedWidgetsView = {
        let view = MixedWidgetsView()
        view.refreshControl.removeFromSuperview()
        return view
    }()
  
    private var storiesRowWidgetView: BlazeStoriesWidgetRowView?
    private var momentsRowWidgetView: BlazeMomentsWidgetRowView?
    private var storiesGridWidgetView: BlazeStoriesWidgetGridView?

    override func loadView() {
        contentView.refreshControl.removeFromSuperview()
        self.view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.enableBlazeSDKAds()
        initWidgets()
    }
    
    func initWidgets() {
        initStoriesRowWidget()
        initMomentsRowWidget()
        initStoriesGirdWidget()
    }
    
    ///
    /// Initialize the stories row widget.
    /// For more information on the ads configuration, refer to
    /// https://dev.wsc-sports.com/docs/ios-blaze-ads-config-type#/blazestoriesadsconfigtype
    ///
    func initStoriesRowWidget() {
        let widgetLayout = BlazeWidgetLayout.Presets.StoriesWidget.Row.circles
        
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(ConfigManager.storiesAdsCustomNativeLabel)
        )
        
        let widget = BlazeStoriesWidgetRowView(layout: widgetLayout)
        widget.adsConfigType = .firstAvailableAdsConfig
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = "ads-stories-row-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        self.storiesRowWidgetView = widget

        let section = WidgetSectionView.init(height: 160, title: "Custom native ads")
        widget.embedInView(section.containerView)
        widget.reloadData(progressType: .skeleton)
        contentView.stackView.addArrangedSubview(section)
    }
    
    ///
    /// Initialize the moment row widget.
    /// For more information on the ads configuration, refer to
    /// https://dev.wsc-sports.com/docs/ios-blaze-ads-config-type#/blazemomentsadsconfigtype
    ///
    func initMomentsRowWidget() {
        let widgetLayout = BlazeWidgetLayout.Presets.MomentsWidget.Row.verticalAnimatedThumbnailsRectangles
        
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(ConfigManager.momentsRowLabel)
        )
        
        let widget = BlazeMomentsWidgetRowView(layout: widgetLayout)
        widget.adsConfigType = .everyXMoments
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = "ads-moments-row-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        self.momentsRowWidgetView = widget
        
        let section = WidgetSectionView.init(height: 300, title: "IMA Ads")
        widget.embedInView(section.containerView)
        widget.reloadData(progressType: .skeleton)
        contentView.stackView.addArrangedSubview(section)
    }
    
    ///
    /// Initialize the stories grid widget.
    /// For more information on the ads configuration, refer to
    /// https://dev.wsc-sports.com/docs/ios-blaze-ads-config-type#/blazestoriesadsconfigtype
    ///
    func initStoriesGirdWidget() {
        let widgetLayout = BlazeWidgetLayout.Presets.StoriesWidget.Grid.twoColumnsVerticalRectangles
        
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(ConfigManager.storiesAdsBannerLabel)
        )
        
        let widget = BlazeStoriesWidgetGridView(layout: widgetLayout)
        widget.adsConfigType = .firstAvailableAdsConfig
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = "ads-stories-grid-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        widget.isEmbededInScrollView = true

        self.storiesGridWidgetView = widget
        
        let section = WidgetSectionView.init(title: "Banners ad")
        widget.embedInView(section.containerView)
        widget.reloadData(progressType: .skeleton)
        contentView.stackView.addArrangedSubview(section)
    }
}
