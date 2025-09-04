//
//  StoriesViewController.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 13/06/2025.
//

import UIKit
import BlazeSDK
import SwiftUICore

///
/// `StoriesRowViewController` is a view controller that displays a grid of Moments content.
/// It manages widget initialization, style customization, and data source updates.
/// For more information on `StoriesRowViewController`, see:
/// https://dev.wsc-sports.com/docs/ios-widgets#/stories-row
///

class StoriesRowViewController: BaseWidgetEditOptionsViewController {
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override init(viewModel: WidgetsViewModel = WidgetsViewModel(widgetType: .storiesRow)) {
        super.init(viewModel: viewModel)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateWidgetHeightParams(styleState: WidgetLayoutStyleState) {
        setContentViewFixedHeight(styleState.isCustomAppearance ? 180 : 140)
    }

    override func initWidgetView() {
        // ⚠️ Important: If you need to customize the layout (e.g., number of columns, spacing, etc.),
        // do it *before* initializing the widget and pass the layout during creation.
        // Using `reloadLayout` later is intended only for rare runtime layout changes
        // and is generally **not** the recommended approach.
        let widgetLayout = viewModel.getWidgetLayoutBasePreset()
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(viewModel.widgetDataState.labelName),
            orderType: viewModel.widgetDataState.orderType
        )
        let widget = BlazeStoriesWidgetRowView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = viewModel.currentWidgetType.rawValue // Or any unique identifier for the widget
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        widget.embedInView(contentView)
        widget.reloadData(progressType: .skeleton)
        self.widgetView = widget
    }

    override func onNewDatasourceState(_ newDataState: WidgetDataState) {
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(newDataState.labelName),
            orderType: newDataState.orderType
        )
        widgetView?.updateDataSourceType(dataSourceType: dataSource, progressType: .skeleton)
    }

    override func onNewWidgetLayoutState(_ styleState: WidgetLayoutStyleState) {
        updateWidgetHeightParams(styleState: styleState)
        
        var layout = styleState.isCustomAppearance
            ? BlazeWidgetLayout.Presets.StoriesWidget.Row.verticalRectangles
            : viewModel.getWidgetLayoutBasePreset()

        layout.horizontalItemsSpacing = 8
        
        if (styleState.isCustomAppearance) {
            setMyCustomImageStyle(for: &layout.widgetItemStyle.image)
        }
        
        if styleState.isCustomStatusIndicator {
            setMyCustomStatusIndicatorStyle(for: &layout.widgetItemStyle.statusIndicator)
        }
        
        if styleState.isCustomTitle {
            setMyCustomTitleStyle(for: &layout.widgetItemStyle.title)
        }
        
        if styleState.isCustomBadge {
            setMyCustomBadgeStyle(for: &layout.widgetItemStyle.badge)
        }
        
        widgetView?.reloadLayout(with: layout)

        if styleState.isCustomItemStyleOverrides {
            setOverrideStylesByTeamId(widgetLayout: layout)
        } else {
            widgetView?.resetOverriddenStyles()
        }
    }
    
    // for more information see https://dev.wsc-sports.com/docs/ios-blaze-widget-item-image-style
    private func setMyCustomImageStyle(for imageStyle: inout BlazeWidgetItemImageStyle) {
        imageStyle.width = 120.0
        imageStyle.height = 168.0
        imageStyle.position = .topCenter
        imageStyle.cornerRadius = 6
        imageStyle.cornerRadiusRatio = 0
        
        imageStyle.border.isVisible = true
       
        let borderColor = UIColor(hex: "0x282828")!
        let borderWidth: CGFloat = 3
       
        imageStyle.border.liveUnreadState.width = borderWidth
        imageStyle.border.liveUnreadState.color = borderColor
        imageStyle.border.liveUnreadState.insets = 0

        imageStyle.border.liveReadState.width = borderWidth
        imageStyle.border.liveReadState.color = borderColor
        imageStyle.border.liveReadState.insets = 0
        
        imageStyle.border.unreadState.width = borderWidth
        imageStyle.border.unreadState.color = borderColor
        imageStyle.border.unreadState.insets = 0
        
        imageStyle.border.readState.width = borderWidth
        imageStyle.border.readState.color = borderColor
        imageStyle.border.readState.insets = 0
        
        imageStyle.gradientOverlay.isVisible = true
        imageStyle.gradientOverlay.startColor = .clear
        imageStyle.gradientOverlay.endColor = UIColor(hex: "0x000000")!
        imageStyle.gradientOverlay.position = .bottom
    }
    
    // for more information see https://dev.wsc-sports.com/docs/ios-blaze-widget-item-status-indicator-style
    private func setMyCustomStatusIndicatorStyle(for statusIndicatorStyle: inout BlazeWidgetItemStatusIndicatorStyle) {
        statusIndicatorStyle.isVisible = true
        statusIndicatorStyle.position.xPosition = .centerX(offset: 0)
        statusIndicatorStyle.position.yPosition = .topToTop(offset: 0)

        let customText = "94:85"
        let customBackgroundColor = UIColor.init(hex: "0x00B27C")!
        let customBorderColor = UIColor.init(hex: "0xCFFFC2")!
        let customBorderWidth: CGFloat = 1
        let customCornerRadius: CGFloat = 8
        let customTextSize: CGFloat = 11
        
        statusIndicatorStyle.liveUnreadState.isVisible = false
        statusIndicatorStyle.liveUnreadState.backgroundColor = customBackgroundColor
        statusIndicatorStyle.liveUnreadState.text = customText
        statusIndicatorStyle.liveUnreadState.textStyle.font = .systemFont(ofSize: customTextSize)
        statusIndicatorStyle.liveUnreadState.cornerRadius = customCornerRadius
        statusIndicatorStyle.liveUnreadState.cornerRadiusRatio = nil
        statusIndicatorStyle.liveUnreadState.borderColor = customBorderColor
        statusIndicatorStyle.liveUnreadState.borderWidth = customBorderWidth
        
        statusIndicatorStyle.liveReadState.isVisible = true
        statusIndicatorStyle.liveReadState.backgroundColor = customBackgroundColor
        statusIndicatorStyle.liveReadState.text = customText
        statusIndicatorStyle.liveReadState.textStyle.font = .systemFont(ofSize: customTextSize)
        statusIndicatorStyle.liveReadState.cornerRadius = customCornerRadius
        statusIndicatorStyle.liveReadState.cornerRadiusRatio = nil
        statusIndicatorStyle.liveReadState.borderColor = customBorderColor
        statusIndicatorStyle.liveReadState.borderWidth = customBorderWidth
        
        statusIndicatorStyle.unreadState.isVisible = true
        statusIndicatorStyle.unreadState.backgroundColor = customBackgroundColor
        statusIndicatorStyle.unreadState.text = customText
        statusIndicatorStyle.unreadState.textStyle.font = .systemFont(ofSize: customTextSize)
        statusIndicatorStyle.unreadState.cornerRadius = customCornerRadius
        statusIndicatorStyle.unreadState.cornerRadiusRatio = nil
        statusIndicatorStyle.unreadState.borderColor = customBorderColor
        statusIndicatorStyle.unreadState.borderWidth = customBorderWidth

        statusIndicatorStyle.readState.isVisible = true
        statusIndicatorStyle.readState.backgroundColor = customBackgroundColor
        statusIndicatorStyle.readState.text = customText
        statusIndicatorStyle.readState.textStyle.font = .systemFont(ofSize: customTextSize)
        statusIndicatorStyle.readState.cornerRadius = customCornerRadius
        statusIndicatorStyle.readState.cornerRadiusRatio = nil
        statusIndicatorStyle.readState.borderColor = customBorderColor
        statusIndicatorStyle.readState.borderWidth = customBorderWidth
    }
    
    // for more information see https://dev.wsc-sports.com/docs/ios-blaze-widget-item-title-style
    func setMyCustomTitleStyle(for titleStyle: inout BlazeWidgetItemTitleStyle) {
        titleStyle.isVisible = true
        
        let customTextColor = UIColor.init(hex: "0xA7C7FF")!
        let customFont = UIFont.italicSystemFont(ofSize: 14)
       
        titleStyle.readState.font = customFont
        titleStyle.readState.numberOfLines = 2
        titleStyle.readState.textColor = customTextColor
        
        titleStyle.unreadState.font = customFont
        titleStyle.unreadState.numberOfLines = 2
        titleStyle.unreadState.textColor = customTextColor
    }
    
    // for more information see https://dev.wsc-sports.com/docs/blazewidgetitembadgestyle#/
    func setMyCustomBadgeStyle(for badgeStyle: inout BlazeWidgetItemBadgeStyle) {
        badgeStyle.isVisible = true
        badgeStyle.position.xPosition = .trailingToTrailing(offset: 0)
        badgeStyle.position.yPosition = .topToTop(offset: 0)
        
        let customImage = UIImage(named: "flag_us")
        let customBorderColor: UIColor = .white
        let customBorderWidth: CGFloat = 1
        let customWidth: CGFloat = 24
        let customHeight: CGFloat = 24
        
        // Inorder to see the border we need to set the padding to the same value as the border width.
        badgeStyle.insets = .init(
            top: customBorderWidth,
            leading: customBorderWidth,
            bottom: customBorderWidth,
            trailing: customBorderWidth
        )
        
        badgeStyle.unreadState.backgroundImage = customImage
        badgeStyle.unreadState.width = customWidth
        badgeStyle.unreadState.height = customHeight
        badgeStyle.unreadState.borderColor = customBorderColor
        badgeStyle.unreadState.borderWidth = customBorderWidth
        
        badgeStyle.readState.backgroundImage = customImage
        badgeStyle.readState.width = customWidth
        badgeStyle.readState.height = customHeight
        badgeStyle.readState.borderColor = customBorderColor
        badgeStyle.readState.borderWidth = customBorderWidth

        badgeStyle.liveUnreadState.backgroundImage = customImage
        badgeStyle.liveUnreadState.width = customWidth
        badgeStyle.liveUnreadState.height = customHeight
        badgeStyle.liveUnreadState.borderColor = customBorderColor
        badgeStyle.liveUnreadState.borderWidth = customBorderWidth

        badgeStyle.liveReadState.backgroundImage = customImage
        badgeStyle.liveReadState.width = customWidth
        badgeStyle.liveReadState.height = customHeight
        badgeStyle.liveReadState.borderColor = customBorderColor
        badgeStyle.liveReadState.borderWidth = customBorderWidth
    }
    
    // Example of setting custom styles for a specific widget item by it team ID.
    // We get the mapping key and value from the BE, inside the item object entities field.
    // For more information see https://dev.wsc-sports.com/docs/blazewidgetitemcustommapping#/
    private func setOverrideStylesByTeamId(widgetLayout: BlazeWidgetLayout) {
        let mappingKey = BlazeWidgetItemCustomMapping.KeysPresets.teamId
        let mappingValue = "178"
        let mapping = BlazeWidgetItemCustomMapping(keyPreset: mappingKey, value: mappingValue)
        let layout = widgetLayout
        let styleOverrides = getBlazeWidgetItemStyleOverrides(newWidgetLayout: layout)
        widgetView?.updateOverrideStyles(stylesPerItem: [mapping : styleOverrides], shouldUpdateUI: true)
    }
    
    // For more information see https://dev.wsc-sports.com/docs/blazewidgetitemstyleoverrides#/
    private func getBlazeWidgetItemStyleOverrides(newWidgetLayout: BlazeWidgetLayout) -> BlazeWidgetItemStyleOverrides {
        // MARK: - Constants
        let borderColor = UIColor(hex: "#8E1616")!
        let badgeBorderColor = UIColor.white
        let badgeImage = UIImage(named: "flag_us")
        let badgeSize: CGFloat = 24
        let badgeBorderWidth: CGFloat = 1
        let badgePadding: CGFloat = 1
        let statusBackgroundColor = UIColor(hex: "#8E1616")!
        let statusBorderColor = UIColor(hex: "#FF6161")!
        let statusCornerRadius: CGFloat = 4
        let statusBorderWidth: CGFloat = 1
        let statusText = "Breaking"

        // MARK: - Image Border
        var imageBorder = newWidgetLayout.widgetItemStyle.image.border
        imageBorder.isVisible = true
        imageBorder.readState.color = borderColor
        imageBorder.unreadState.color = borderColor
        imageBorder.liveReadState.color = borderColor
        imageBorder.liveUnreadState.color = borderColor

        // MARK: - Badge
        var badge = newWidgetLayout.widgetItemStyle.badge
        badge.isVisible = true
        badge.position.xPosition = .trailingToTrailing(offset: 0)
        badge.position.yPosition = .topToTop(offset: 0)
        badge.insets = .init(top: badgePadding, leading: badgePadding, bottom: badgePadding, trailing: badgePadding)

        badge.unreadState.backgroundImage = badgeImage
        badge.unreadState.width = badgeSize
        badge.unreadState.height = badgeSize
        badge.unreadState.borderColor = badgeBorderColor
        badge.unreadState.borderWidth = badgeBorderWidth

        badge.readState.backgroundImage = badgeImage
        badge.readState.width = badgeSize
        badge.readState.height = badgeSize
        badge.readState.borderColor = badgeBorderColor
        badge.readState.borderWidth = badgeBorderWidth

        badge.liveUnreadState.backgroundImage = badgeImage
        badge.liveUnreadState.width = badgeSize
        badge.liveUnreadState.height = badgeSize
        badge.liveUnreadState.borderColor = badgeBorderColor
        badge.liveUnreadState.borderWidth = badgeBorderWidth

        badge.liveReadState.backgroundImage = badgeImage
        badge.liveReadState.width = badgeSize
        badge.liveReadState.height = badgeSize
        badge.liveReadState.borderColor = badgeBorderColor
        badge.liveReadState.borderWidth = badgeBorderWidth

        // MARK: - Status Indicator
        var statusIndicator = newWidgetLayout.widgetItemStyle.statusIndicator
        statusIndicator.position.xPosition = .leadingToLeading(offset: 0)
        statusIndicator.position.yPosition = .centerToBottom(offset: 0)
        statusIndicator.insets = .zero

        statusIndicator.unreadState.backgroundColor = statusBackgroundColor
        statusIndicator.unreadState.text = statusText
        statusIndicator.unreadState.cornerRadius = statusCornerRadius
        statusIndicator.unreadState.cornerRadiusRatio = nil
        statusIndicator.unreadState.borderColor = statusBorderColor
        statusIndicator.unreadState.borderWidth = statusBorderWidth

        statusIndicator.readState.backgroundColor = statusBackgroundColor
        statusIndicator.readState.text = statusText
        statusIndicator.readState.cornerRadius = statusCornerRadius
        statusIndicator.readState.cornerRadiusRatio = nil
        statusIndicator.readState.borderColor = statusBorderColor
        statusIndicator.readState.borderWidth = statusBorderWidth

        statusIndicator.liveUnreadState.backgroundColor = statusBackgroundColor
        statusIndicator.liveUnreadState.text = statusText
        statusIndicator.liveUnreadState.cornerRadius = statusCornerRadius
        statusIndicator.liveUnreadState.cornerRadiusRatio = nil
        statusIndicator.liveUnreadState.borderColor = statusBorderColor
        statusIndicator.liveUnreadState.borderWidth = statusBorderWidth

        statusIndicator.liveReadState.backgroundColor = statusBackgroundColor
        statusIndicator.liveReadState.text = statusText
        statusIndicator.liveReadState.cornerRadius = statusCornerRadius
        statusIndicator.liveReadState.cornerRadiusRatio = nil
        statusIndicator.liveReadState.borderColor = statusBorderColor
        statusIndicator.liveReadState.borderWidth = statusBorderWidth

        return BlazeWidgetItemStyleOverrides(
            statusIndicator: statusIndicator,
            imageBorder: imageBorder,
            badge: badge
        )
    }
}

