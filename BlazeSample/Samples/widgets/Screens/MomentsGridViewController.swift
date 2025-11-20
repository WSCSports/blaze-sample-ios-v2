//
//  MomentsGridViewController.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 20/06/2025.
//

import UIKit
import BlazeSDK
import SwiftUI


///
/// `MomentsGridViewController` is a view controller that displays a grid of Moments content.
/// It manages widget initialization, style customization, and data source updates.
/// For more information on `BlazeMomentsWidgetGridView`, see:
/// https://dev.wsc-sports.com/docs/ios-widgets#/moments-grid
///

class MomentsGridViewController: BaseWidgetEditOptionsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContentViewBottomAnchor(to: shadowView.topAnchor)
    }
    
    override init(viewModel: WidgetsViewModel = WidgetsViewModel(widgetType: .momentsGrid)) {
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
        
        let widget = BlazeMomentsWidgetGridView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = viewModel.currentWidgetType.rawValue
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        widget.embedInView(contentView)
        widget.reloadData(progressType: .skeleton)
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
            setMyCustomTitleStyle(for: &layout.widgetItemStyle)
        }
        
        if styleState.isCustomBadge {
            setMyCustomBadgeStyle(for: &layout.widgetItemStyle.badge)
        }
        
        widgetView?.reloadLayout(with: layout)
        
        if styleState.isCustomItemStyleOverrides {
            setOverrideStylesBySeasonId(widgetLayout: layout)
        } else {
            widgetView?.resetOverriddenStyles()
        }
    }
    
    // for more information see https://dev.wsc-sports.com/docs/ios-blaze-widget-item-image-style
    private func setMyCustomImageStyle(for imageStyle: inout BlazeWidgetItemImageStyle) {
        imageStyle.position = .topCenter
        imageStyle.cornerRadius = 16
        imageStyle.cornerRadiusRatio = nil
        imageStyle.border.isVisible = true
        
        let borderColor = UIColor(hex: "0x0057FF")!
        let borderWidth: CGFloat = 4
        
        imageStyle.border.liveUnreadState.width = borderWidth
        imageStyle.border.liveUnreadState.color = borderColor
        
        imageStyle.border.liveReadState.width = borderWidth
        imageStyle.border.liveReadState.color = borderColor
        
        imageStyle.border.unreadState.width = borderWidth
        imageStyle.border.unreadState.color = borderColor
        
        imageStyle.border.readState.width = borderWidth
        imageStyle.border.readState.color = borderColor
        
        imageStyle.gradientOverlay.isVisible = true
        imageStyle.gradientOverlay.startColor = UIColor(hex: "0xAA000000")!
        imageStyle.gradientOverlay.endColor = UIColor(hex: "0x00000000")!
        imageStyle.gradientOverlay.position = .bottom
    }
    
    // for more information see https://dev.wsc-sports.com/docs/ios-blaze-widget-item-status-indicator-style
    private func setMyCustomStatusIndicatorStyle(for statusIndicatorStyle: inout BlazeWidgetItemStatusIndicatorStyle) {
        statusIndicatorStyle.isVisible = true
        statusIndicatorStyle.position.xPosition = .trailingToTrailing(offset: -6)
        statusIndicatorStyle.position.yPosition = .bottomToBottom(offset: -6)
        
        let backgroundColor = UIColor(hex: "0xE5FF00")!
        let textColor = UIColor(hex: "0x3F3F2B")!
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
    
    // for more information see https://dev.wsc-sports.com/docs/ios-blaze-widget-item-title-style#/
    private func setMyCustomTitleStyle(for widgetItemStyle: inout BlazeWidgetItemStyle) {
        
        widgetItemStyle.image.ratio = 0.75

        widgetItemStyle.title.isVisible = true
        widgetItemStyle.title.position.xPosition = .leadingToLeading(offset: 0)
        widgetItemStyle.title.position.yPosition = .topToBottom(offset: 5)
        
        let textColor = UIColor.black
        let font = UIFont.italicSystemFont(ofSize: 14)
        
        widgetItemStyle.title.readState.font = font
        widgetItemStyle.title.readState.textColor = textColor
        widgetItemStyle.title.readState.numberOfLines = 1
        
        widgetItemStyle.title.unreadState.font = font
        widgetItemStyle.title.unreadState.textColor = textColor
        widgetItemStyle.title.unreadState.numberOfLines = 1
    }
    
    // for more information see https://dev.wsc-sports.com/docs/blazewidgetitembadgestyle#/
    private func setMyCustomBadgeStyle(for badgeStyle: inout BlazeWidgetItemBadgeStyle) {
        badgeStyle.isVisible = true
        badgeStyle.position.xPosition = .centerToTrailing(offset: -3)
        badgeStyle.position.yPosition = .centerToTop(offset: 3)

        let text = "3"
        let backgroundColor = UIColor(hex: "0xFF3131")!
        let textColor = UIColor.white
        let borderColor = UIColor.white
        let textSize: CGFloat = 14
        let size: CGFloat = 24
        let borderWidth: CGFloat = 1
        
        badgeStyle.insets = .init(top: borderWidth, leading: borderWidth, bottom: borderWidth, trailing: borderWidth)
        
        badgeStyle.unreadState.text = text
        badgeStyle.unreadState.textStyle.font = .systemFont(ofSize: textSize)
        badgeStyle.unreadState.textStyle.textColor = textColor
        badgeStyle.unreadState.backgroundColor = backgroundColor
        badgeStyle.unreadState.width = size
        badgeStyle.unreadState.height = size
        badgeStyle.unreadState.borderColor = borderColor
        badgeStyle.unreadState.borderWidth = borderWidth
        
        badgeStyle.readState.text = text
        badgeStyle.readState.textStyle.font = .systemFont(ofSize: textSize)
        badgeStyle.readState.textStyle.textColor = textColor
        badgeStyle.readState.backgroundColor = backgroundColor
        badgeStyle.readState.width = size
        badgeStyle.readState.height = size
        badgeStyle.readState.borderColor = borderColor
        badgeStyle.readState.borderWidth = borderWidth
        
        badgeStyle.liveUnreadState.text = text
        badgeStyle.liveUnreadState.textStyle.font = .systemFont(ofSize: textSize)
        badgeStyle.liveUnreadState.textStyle.textColor = textColor
        badgeStyle.liveUnreadState.backgroundColor = backgroundColor
        badgeStyle.liveUnreadState.width = size
        badgeStyle.liveUnreadState.height = size
        badgeStyle.liveUnreadState.borderColor = borderColor
        badgeStyle.liveUnreadState.borderWidth = borderWidth
        
        badgeStyle.liveReadState.text = text
        badgeStyle.liveReadState.textStyle.font = .systemFont(ofSize: textSize)
        badgeStyle.liveReadState.textStyle.textColor = textColor
        badgeStyle.liveReadState.backgroundColor = backgroundColor
        badgeStyle.liveReadState.width = size
        badgeStyle.liveReadState.height = size
        badgeStyle.liveReadState.borderColor = borderColor
        badgeStyle.liveReadState.borderWidth = borderWidth
    }
    
    // Example of setting custom styles for a specific widget item by it season ID.
    // We get the mapping key and value from the BE, inside the item object entities field.
    // For more information see https://dev.wsc-sports.com/docs/blazewidgetitemcustommapping#/
    private func setOverrideStylesBySeasonId(widgetLayout: BlazeWidgetLayout) {
        let mappingKey = BlazeWidgetItemCustomMapping.KeysPresets.seasonId
        let mappingValue = "2025"
        let mapping = BlazeWidgetItemCustomMapping(keyPreset: mappingKey, value: mappingValue)
        let layout = widgetLayout
        let styleOverrides = getBlazeWidgetItemStyleOverrides(newWidgetLayout: layout)
        widgetView?.updateOverrideStyles(stylesPerItem: [mapping : styleOverrides], shouldUpdateUI: true)
    }
    
    private func getBlazeWidgetItemStyleOverrides(newWidgetLayout: BlazeWidgetLayout) -> BlazeWidgetItemStyleOverrides {
        let borderColor = UIColor(hex: "0x2FB2A5")!
        let borderWidth: CGFloat = 4
        
        let badgeColor = UIColor(hex: "0xCAFFFA")!
        let badgeTextColor = UIColor(hex: "0x2FB2A5")!
        let badgeText = "1"
        let badgeSize: CGFloat = 24
        let badgeBorderWidth: CGFloat = 1
        let badgeBorderColor = UIColor(hex: "0x2FB2A5")!
        
        let statusColor = UIColor(hex: "0x2FB2A5")!
        let statusTextColor = UIColor.white
        let statusBorderColor = UIColor.white
        let statusCornerRadius: CGFloat = 4
        let statusBorderWidth: CGFloat = 1
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        var imageBorder = newWidgetLayout.widgetItemStyle.image.border
        imageBorder.isVisible = true
        
        imageBorder.readState.color = borderColor
        imageBorder.readState.width = borderWidth
        imageBorder.unreadState.color = borderColor
        imageBorder.unreadState.width = borderWidth
        imageBorder.liveReadState.color = borderColor
        imageBorder.liveReadState.width = borderWidth
        imageBorder.liveUnreadState.color = borderColor
        imageBorder.liveUnreadState.width = borderWidth
        
        var badge = newWidgetLayout.widgetItemStyle.badge
        badge.isVisible = true
        badge.position.xPosition = .centerToTrailing(offset: -3)
        badge.position.yPosition = .centerToTop(offset: 3)

        badge.readState.text = badgeText
        badge.readState.textStyle.textColor = badgeTextColor
        badge.readState.textStyle.font = font
        badge.readState.backgroundColor = badgeColor
        badge.readState.width = badgeSize
        badge.readState.height = badgeSize
        badge.readState.borderColor = badgeBorderColor
        badge.readState.borderWidth = badgeBorderWidth
        
        badge.unreadState.text = badgeText
        badge.unreadState.textStyle.textColor = badgeTextColor
        badge.unreadState.textStyle.font = font
        badge.unreadState.backgroundColor = badgeColor
        badge.unreadState.width = badgeSize
        badge.unreadState.height = badgeSize
        badge.unreadState.borderColor = badgeBorderColor
        badge.unreadState.borderWidth = badgeBorderWidth
        
        badge.liveReadState.text = badgeText
        badge.liveReadState.textStyle.textColor = badgeTextColor
        badge.liveReadState.textStyle.font = font
        badge.liveReadState.backgroundColor = badgeColor
        badge.liveReadState.width = badgeSize
        badge.liveReadState.height = badgeSize
        badge.liveReadState.borderColor = badgeBorderColor
        badge.liveReadState.borderWidth = badgeBorderWidth
        
        badge.liveUnreadState.text = badgeText
        badge.liveUnreadState.textStyle.textColor = badgeTextColor
        badge.liveUnreadState.textStyle.font = font
        badge.liveUnreadState.backgroundColor = badgeColor
        badge.liveUnreadState.width = badgeSize
        badge.liveUnreadState.height = badgeSize
        badge.liveUnreadState.borderColor = badgeBorderColor
        badge.liveUnreadState.borderWidth = badgeBorderWidth
        
        var statusIndicator = newWidgetLayout.widgetItemStyle.statusIndicator
        statusIndicator.position.xPosition = .leadingToLeading(offset: 7)
        statusIndicator.position.yPosition = .bottomToBottom(offset: -25)

        statusIndicator.isVisible = true
        
        statusIndicator.readState.isVisible = true
        statusIndicator.readState.backgroundColor = statusColor
        statusIndicator.readState.text = "New"
        statusIndicator.readState.textStyle.font = font
        statusIndicator.readState.textStyle.textColor = statusTextColor
        statusIndicator.readState.cornerRadius = statusCornerRadius
        statusIndicator.readState.cornerRadiusRatio = nil
        statusIndicator.readState.borderColor = statusBorderColor
        statusIndicator.readState.borderWidth = statusBorderWidth
        
        statusIndicator.unreadState.isVisible = true
        statusIndicator.unreadState.backgroundColor = statusColor
        statusIndicator.unreadState.text = "New"
        statusIndicator.unreadState.textStyle.font = font
        statusIndicator.unreadState.textStyle.textColor = statusTextColor
        statusIndicator.unreadState.cornerRadius = statusCornerRadius
        statusIndicator.unreadState.cornerRadiusRatio = nil
        statusIndicator.unreadState.borderColor = statusBorderColor
        statusIndicator.unreadState.borderWidth = statusBorderWidth
        
        statusIndicator.liveReadState.isVisible = true
        statusIndicator.liveReadState.backgroundColor = statusColor
        statusIndicator.liveReadState.text = "New"
        statusIndicator.liveReadState.textStyle.font = font
        statusIndicator.liveReadState.textStyle.textColor = statusTextColor
        statusIndicator.liveReadState.cornerRadius = statusCornerRadius
        statusIndicator.liveReadState.cornerRadiusRatio = nil
        statusIndicator.liveReadState.borderColor = statusBorderColor
        statusIndicator.liveReadState.borderWidth = statusBorderWidth
        
        statusIndicator.liveUnreadState.isVisible = true
        statusIndicator.liveUnreadState.backgroundColor = statusColor
        statusIndicator.liveUnreadState.text = "New"
        statusIndicator.liveUnreadState.textStyle.font = font
        statusIndicator.liveUnreadState.textStyle.textColor = statusTextColor
        statusIndicator.liveUnreadState.cornerRadius = statusCornerRadius
        statusIndicator.liveUnreadState.cornerRadiusRatio = nil
        statusIndicator.liveUnreadState.borderColor = statusBorderColor
        statusIndicator.liveUnreadState.borderWidth = statusBorderWidth
        
        return BlazeWidgetItemStyleOverrides(
            statusIndicator: statusIndicator,
            imageBorder: imageBorder,
            badge: badge
        )
    }
}
