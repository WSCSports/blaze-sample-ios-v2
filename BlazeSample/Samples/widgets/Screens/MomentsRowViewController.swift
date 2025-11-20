//
//  MomentsRowViewController.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 20/06/2025.
//

import UIKit
import BlazeSDK
import SwiftUI

///
/// `MomentsRowViewController` is a view controller that displays a grid of Moments content.
/// It manages widget initialization, style customization, and data source updates.
/// For more information on `BlazeMomentsWidgetGridView`, see:
/// https://dev.wsc-sports.com/docs/ios-widgets#/moments-row
///

class MomentsRowViewController: BaseWidgetEditOptionsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContentViewFixedHeight(300)
    }
    
    override init(viewModel: WidgetsViewModel = WidgetsViewModel(widgetType: .momentsRow)) {
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
        
        let widget = BlazeMomentsWidgetRowView(layout: widgetLayout)
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
            setMyCustomTitleStyle(for: &layout.widgetItemStyle.title)
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
        imageStyle.cornerRadius = 0
        imageStyle.cornerRadiusRatio = nil
        imageStyle.border.isVisible = true
        
        let borderColor = UIColor(hex: "#0057FF")!
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
    }
    
    // for more information see https://dev.wsc-sports.com/docs/ios-blaze-widget-item-status-indicator-style
    private func setMyCustomStatusIndicatorStyle(for statusIndicatorStyle: inout BlazeWidgetItemStatusIndicatorStyle) {
        statusIndicatorStyle.isVisible = true
        statusIndicatorStyle.position.xPosition = .trailingToTrailing(offset: -6)
        statusIndicatorStyle.position.yPosition = .bottomToBottom(offset: -6)
        
        let backgroundColor = UIColor(hex: "#E5FF00")!
        let textColor = UIColor(hex: "#3F3F2B")!
        let text = "NEW"
        let textSize: CGFloat = 12
        let cornerRadius: CGFloat = 8
        
        statusIndicatorStyle.unreadState.isVisible = true
        statusIndicatorStyle.unreadState.backgroundColor = backgroundColor
        statusIndicatorStyle.unreadState.text = text
        statusIndicatorStyle.unreadState.textStyle.textColor = textColor
        statusIndicatorStyle.unreadState.textStyle.font = .systemFont(ofSize: textSize)
        statusIndicatorStyle.unreadState.cornerRadius = cornerRadius
        
        statusIndicatorStyle.readState = statusIndicatorStyle.unreadState
    }
    
    // for more information see https://dev.wsc-sports.com/docs/ios-blaze-widget-item-title-style#/
    private func setMyCustomTitleStyle(for titleStyle: inout BlazeWidgetItemTitleStyle) {
        titleStyle.isVisible = true
        titleStyle.position.xPosition = .leadingToLeading(offset: 0)
        titleStyle.position.yPosition = .bottomToBottom(offset: 22)
        
        let textColor = UIColor(hex: "#83869A")!
        let font = UIFont.italicSystemFont(ofSize: 16)
        
        titleStyle.readState.font = font
        titleStyle.readState.textColor = textColor
        titleStyle.readState.numberOfLines = 1
        
        titleStyle.unreadState = titleStyle.readState
    }
    
    // for more information see https://dev.wsc-sports.com/docs/blazewidgetitembadgestyle#/
    private func setMyCustomBadgeStyle(for badgeStyle: inout BlazeWidgetItemBadgeStyle) {
        badgeStyle.isVisible = true
        badgeStyle.position.xPosition = .centerToTrailing(offset: 4)
        badgeStyle.position.yPosition = .centerToTop(offset: 4)
        
        let backgroundColor = UIColor(hex: "#FF3131")!
        let borderColor = UIColor.white
        let textColor = UIColor.white
        let textSize: CGFloat = 14
        let size: CGFloat = 24
        let borderWidth: CGFloat = 2
        let text = "3"
        
        badgeStyle.unreadState.text = text
        badgeStyle.unreadState.textStyle.font = .systemFont(ofSize: textSize)
        badgeStyle.unreadState.textStyle.textColor = textColor
        badgeStyle.unreadState.backgroundColor = backgroundColor
        badgeStyle.unreadState.width = size
        badgeStyle.unreadState.height = size
        badgeStyle.unreadState.borderColor = borderColor
        badgeStyle.unreadState.borderWidth = borderWidth
        
        badgeStyle.readState = badgeStyle.unreadState
        badgeStyle.liveReadState = badgeStyle.unreadState
        badgeStyle.liveUnreadState = badgeStyle.unreadState
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
        let borderWidth: CGFloat = 1
        
        let badgeColor = UIColor(hex: "#CAFFFA")!
        let badgeSize: CGFloat = 24
        let badgeBorderWidth: CGFloat = 2
        let badgeBorderColor = UIColor(hex: "#2FB2A5")!
        let font = UIFont.systemFont(ofSize: 12)
        let statusIndicatorColor = UIColor(hex: "#2FB2A5")!

        let statusIndicatorText = "NEW"
        
        var imageBorder = newWidgetLayout.widgetItemStyle.image.border
        imageBorder.isVisible = true
        
        imageBorder.readState.color = .white
        imageBorder.readState.width = borderWidth
        imageBorder.unreadState = imageBorder.readState
        imageBorder.liveReadState = imageBorder.readState
        imageBorder.liveUnreadState = imageBorder.readState
        
        var badge = newWidgetLayout.widgetItemStyle.badge
        badge.isVisible = true
        badge.position.xPosition = .centerToTrailing(offset: 4)
        badge.position.yPosition = .centerToTop(offset: 4)
        
        badge.unreadState.text = "1"
        badge.unreadState.textStyle.textColor = badgeBorderColor
        badge.unreadState.textStyle.font = font
        badge.unreadState.backgroundColor = badgeColor
        badge.unreadState.width = badgeSize
        badge.unreadState.height = badgeSize
        badge.unreadState.borderColor = badgeBorderColor
        badge.unreadState.borderWidth = badgeBorderWidth
        
        badge.readState = badge.unreadState
        badge.liveReadState = badge.unreadState
        badge.liveUnreadState = badge.unreadState
        
        var statusIndicator = newWidgetLayout.widgetItemStyle.statusIndicator
        statusIndicator.isVisible = true
        statusIndicator.position.xPosition = .leadingToLeading(offset: 8)
        statusIndicator.position.yPosition = .bottomToBottom(offset: -26)
        
        statusIndicator.unreadState.backgroundColor = statusIndicatorColor
        statusIndicator.unreadState.text = statusIndicatorText
        statusIndicator.unreadState.textStyle.textColor = .white
        statusIndicator.unreadState.textStyle.font = font
        statusIndicator.unreadState.cornerRadius = 4
        statusIndicator.unreadState.borderColor = .white
        statusIndicator.unreadState.borderWidth = 1
        
        statusIndicator.readState.backgroundColor = statusIndicatorColor
        statusIndicator.readState.text = statusIndicatorText
        statusIndicator.readState.textStyle.textColor = .white
        statusIndicator.readState.textStyle.font = font
        statusIndicator.readState.cornerRadius = 4
        statusIndicator.readState.borderColor = .white
        statusIndicator.readState.borderWidth = 1

        statusIndicator.liveReadState.backgroundColor = statusIndicatorColor
        statusIndicator.liveReadState.text = statusIndicatorText
        statusIndicator.liveReadState.textStyle.textColor = .white
        statusIndicator.liveReadState.textStyle.font = font
        statusIndicator.liveReadState.cornerRadius = 4
        statusIndicator.liveReadState.borderColor = .white
        statusIndicator.liveReadState.borderWidth = 1

        statusIndicator.liveUnreadState.backgroundColor = statusIndicatorColor
        statusIndicator.liveUnreadState.text = statusIndicatorText
        statusIndicator.liveUnreadState.textStyle.textColor = .white
        statusIndicator.liveUnreadState.textStyle.font = font
        statusIndicator.liveUnreadState.cornerRadius = 4
        statusIndicator.liveUnreadState.borderColor = .white
        statusIndicator.liveUnreadState.borderWidth = 1
        
        return BlazeWidgetItemStyleOverrides(
            statusIndicator: statusIndicator,
            imageBorder: imageBorder,
            badge: badge
        )
    }
}
