//
//  VideosRowViewController.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 20/06/2025.
//

import UIKit
import BlazeSDK
import SwiftUICore

///
/// `VideosRowViewController` is a view controller that displays a grid of Moments content.
/// It manages widget initialization, style customization, and data source updates.
/// For more information on `BlazeMomentsWidgetGridView`, see:
/// https://dev.wsc-sports.com/docs/ios-widgets#/videos-row
///

class VideosRowViewController: BaseWidgetEditOptionsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContentViewFixedHeight(230)
    }
    
    override init(viewModel: WidgetsViewModel = WidgetsViewModel(widgetType: .videosRow)) {
        super.init(viewModel: viewModel)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        let widget = BlazeVideosWidgetRowView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = viewModel.currentWidgetType.rawValue
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        widget.reloadData(progressType: .skeleton)
        widget.embedInView(contentView)
        self.widgetView = widget
    }
    
    override func onNewWidgetLayoutState(_ styleState: WidgetLayoutStyleState) {
        var layout = viewModel.getWidgetLayoutBasePreset()
        
        if styleState.isCustomAppearance {
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
            setOverrideStylesByGameId(widgetLayout: layout)
        } else {
            widgetView?.resetOverriddenStyles()
        }
    }
    
    // for more information see https://dev.wsc-sports.com/docs/ios-blaze-widget-item-image-style
    private func setMyCustomImageStyle(for imageStyle: inout BlazeWidgetItemImageStyle) {
        imageStyle.position = .topLeading
        imageStyle.cornerRadius = 0
        imageStyle.cornerRadiusRatio = nil
        imageStyle.border.isVisible = true
      
        let borderColor = UIColor(hex: "0xFF60C9")!
        let borderWidth: CGFloat = 3

        imageStyle.border.liveUnreadState.width = borderWidth
        imageStyle.border.liveUnreadState.color = borderColor

        imageStyle.border.liveReadState.width = borderWidth
        imageStyle.border.liveReadState.color = borderColor

        imageStyle.border.unreadState.width = borderWidth
        imageStyle.border.unreadState.color = borderColor
        imageStyle.border.unreadState.insets = 0

        imageStyle.border.readState.width = borderWidth
        imageStyle.border.readState.color = borderColor
    }
    
    // for more information see https://dev.wsc-sports.com/docs/ios-blaze-widget-item-status-indicator-style
    private func setMyCustomStatusIndicatorStyle(for statusIndicatorStyle: inout BlazeWidgetItemStatusIndicatorStyle) {
        statusIndicatorStyle.isVisible = true
        statusIndicatorStyle.position.xPosition = .leadingToLeading(offset: 8)
        statusIndicatorStyle.position.yPosition = .topToTop(offset: 8)

        statusIndicatorStyle.insets = .init(top: 0, leading: 8, bottom: 0, trailing: 12)

        let backgroundColor = UIColor(hex: "0xFFC7F2")!
        let textColor = UIColor(hex: "0x333333")!
        let text = "NEW"
        let textSize: CGFloat = 12
        let cornerRadius: CGFloat = 8

        statusIndicatorStyle.unreadState.isVisible = true
        statusIndicatorStyle.unreadState.backgroundColor = backgroundColor
        statusIndicatorStyle.unreadState.text = text
        statusIndicatorStyle.unreadState.textStyle.textColor = textColor
        statusIndicatorStyle.unreadState.textStyle.font = .systemFont(ofSize: textSize)
        statusIndicatorStyle.unreadState.cornerRadius = cornerRadius

        statusIndicatorStyle.readState.isVisible = true
        statusIndicatorStyle.readState.backgroundColor = backgroundColor
        statusIndicatorStyle.readState.text = text
        statusIndicatorStyle.readState.textStyle.textColor = textColor
        statusIndicatorStyle.readState.textStyle.font = .systemFont(ofSize: textSize)
        statusIndicatorStyle.readState.cornerRadius = cornerRadius
    }
    
    // for more information see https://dev.wsc-sports.com/docs/ios-blaze-widget-item-title-style
    private func setMyCustomTitleStyle(for titleStyle: inout BlazeWidgetItemTitleStyle) {
        titleStyle.isVisible = true
        titleStyle.position.xPosition = .leadingToLeading(offset: 4)
        titleStyle.position.yPosition = .bottomToBottom(offset: -12)

        let textColor = UIColor(hex: "#FFCE66")!
        let font = UIFont.italicSystemFont(ofSize: 17)

        titleStyle.readState.font = font
        titleStyle.readState.textColor = textColor
        titleStyle.readState.numberOfLines = 1

        titleStyle.unreadState.font = font
        titleStyle.unreadState.textColor = textColor
        titleStyle.unreadState.numberOfLines = 1
    }
    
    // for more information see https://dev.wsc-sports.com/docs/blazewidgetitembadgestyle#/
    private func setMyCustomBadgeStyle(for badgeStyle: inout BlazeWidgetItemBadgeStyle) {
        let text = "3"
        let backgroundColor = UIColor(hex: "0xFF3131")!
        let textColor = UIColor.white
        let borderColor = UIColor.white
        let textSize: CGFloat = 14
        let size: CGFloat = 24
        let borderWidth: CGFloat = 1

        badgeStyle.isVisible = true
        badgeStyle.position.xPosition = .trailingToTrailing(offset: 0)
        badgeStyle.position.yPosition = .topToTop(offset: 0)

        badgeStyle.unreadState.text = text
        badgeStyle.unreadState.textStyle.font = .systemFont(ofSize: textSize)
        badgeStyle.unreadState.textStyle.textColor = textColor
        badgeStyle.unreadState.backgroundColor = backgroundColor
        badgeStyle.unreadState.width = size
        badgeStyle.unreadState.height = size
        badgeStyle.unreadState.borderColor = borderColor
        badgeStyle.unreadState.borderWidth = borderWidth

        badgeStyle.readState = badgeStyle.unreadState
        badgeStyle.liveUnreadState = badgeStyle.unreadState
        badgeStyle.liveReadState = badgeStyle.unreadState
    }
    
    // Example of setting custom styles for a specific widget item by it game ID.
    // We get the mapping key and value from the BE, inside the item object entities field.
    // For more information see https://dev.wsc-sports.com/docs/blazewidgetitemcustommapping#/
    private func setOverrideStylesByGameId(widgetLayout: BlazeWidgetLayout) {
        let mappingKey = BlazeWidgetItemCustomMapping.KeysPresets.gameId
        let mappingValue = "2445381"
        let mapping = BlazeWidgetItemCustomMapping(keyPreset: mappingKey, value: mappingValue)
        let layout = widgetLayout
        let styleOverrides = getBlazeWidgetItemStyleOverrides(newWidgetLayout: layout)
        widgetView?.updateOverrideStyles(stylesPerItem: [mapping : styleOverrides], shouldUpdateUI: true)
    }
    
    private func getBlazeWidgetItemStyleOverrides(newWidgetLayout: BlazeWidgetLayout) -> BlazeWidgetItemStyleOverrides {
        let borderColor = UIColor(hex: "0x67FFF5")!
        let borderWidth: CGFloat = 1

        let badgeColor = UIColor(hex: "0xCAFFFA")!
        let badgeBorderColor = UIColor(hex: "0x2FB2A5")!
        let badgeTextColor = UIColor(hex: "0x2FB2A5")!
        let badgeSize: CGFloat = 24
        let badgeBorderWidth: CGFloat = 2

        let statusColor = UIColor(hex: "0xCAFFFA")!
        let statusTextColor = UIColor(hex: "0x2FB2A5")!
        let statusText = "NEW"
        let statusTextSize: CGFloat = 12
        let statusCornerRadius: CGFloat = 8

        // Image border override
        var imageBorder = newWidgetLayout.widgetItemStyle.image.border
        imageBorder.isVisible = true

        imageBorder.readState.color = borderColor
        imageBorder.readState.width = borderWidth
        imageBorder.readState.insets = 0

        imageBorder.unreadState.color = borderColor
        imageBorder.unreadState.width = borderWidth
        imageBorder.unreadState.insets = 0

        imageBorder.liveReadState.color = borderColor
        imageBorder.liveReadState.width = borderWidth
        imageBorder.liveReadState.insets = 0

        imageBorder.liveUnreadState.color = borderColor
        imageBorder.liveUnreadState.width = borderWidth
        imageBorder.liveUnreadState.insets = 0

        // Badge override
        var badge = newWidgetLayout.widgetItemStyle.badge
        badge.isVisible = true
        badge.position.xPosition = .centerToTrailing(offset: 0)
        badge.position.yPosition = .centerToTop(offset: 0)

        badge.insets = .init(top: -10, leading: 0, bottom: 0, trailing: -10)

        badge.unreadState.backgroundColor = badgeColor
        badge.unreadState.width = badgeSize
        badge.unreadState.height = badgeSize
        badge.unreadState.borderColor = badgeBorderColor
        badge.unreadState.borderWidth = badgeBorderWidth
        badge.unreadState.textStyle.textColor = badgeTextColor
        badge.unreadState.text = ""
        
        badge.readState = badge.unreadState
        badge.liveReadState = badge.unreadState
        badge.liveUnreadState = badge.unreadState

        // Status Indicator override
        var statusIndicator = newWidgetLayout.widgetItemStyle.statusIndicator
        statusIndicator.isVisible = true
        statusIndicator.position.xPosition = .leadingToLeading(offset: 8)
        statusIndicator.position.yPosition = .topToTop(offset: 8)
        statusIndicator.insets = .init(top: 0, leading: 8, bottom: 0, trailing: 12)

        statusIndicator.unreadState.backgroundColor = statusColor
        statusIndicator.unreadState.text = statusText
        statusIndicator.unreadState.textStyle.textColor = statusTextColor
        statusIndicator.unreadState.textStyle.font = .systemFont(ofSize: statusTextSize)
        statusIndicator.unreadState.cornerRadius = statusCornerRadius

        statusIndicator.readState = statusIndicator.unreadState
        statusIndicator.liveReadState = statusIndicator.unreadState
        statusIndicator.liveUnreadState = statusIndicator.unreadState

        return BlazeWidgetItemStyleOverrides(
            statusIndicator: statusIndicator,
            imageBorder: imageBorder,
            badge: badge
        )
    }
}
