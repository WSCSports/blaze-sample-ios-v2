//
//  StoriesGridViewController.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 19/06/2025.
//

import UIKit
import BlazeSDK
import SwiftUICore

///
/// `StoriesGridViewController` is a view controller that displays a grid of Moments content.
/// It manages widget initialization, style customization, and data source updates.
/// For more information on `StoriesGridViewController`, see:
/// https://dev.wsc-sports.com/docs/ios-widgets#/stories-grid
///

class StoriesGridViewController: BaseWidgetEditOptionsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContentViewBottomAnchor(to: shadowView.topAnchor)
    }
    
    override init(viewModel: WidgetsViewModel = WidgetsViewModel(widgetType: .storiesGrid)) {
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

        let widget = BlazeStoriesWidgetGridView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = viewModel.currentWidgetType.rawValue
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        widget.embedInView(contentView)
        widget.reloadData(progressType: .skeleton)
        self.widgetView = widget
    }

    override func onNewWidgetLayoutState(_ styleState: WidgetLayoutStyleState) {

        var layout = styleState.isCustomAppearance
        ? BlazeWidgetLayout.Presets.StoriesWidget.Grid.twoColumnsVerticalRectangles
        : viewModel.getWidgetLayoutBasePreset()

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
            setOverrideStylesByTeamId(widgetLayout: layout)
        } else {
            widgetView?.resetOverriddenStyles()
        }
    }
    
    override func onNewDatasourceState(_ newDataState: WidgetDataState) {
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(newDataState.labelName),
            orderType: newDataState.orderType
        )
        widgetView?.updateDataSourceType(dataSourceType: dataSource, progressType: .skeleton)
    }
    
    // for more information see https://dev.wsc-sports.com/docs/ios-blaze-widget-item-image-style
    private func setMyCustomImageStyle(for imageStyle: inout BlazeWidgetItemImageStyle) {
        imageStyle.position = .center
        imageStyle.cornerRadius = 20
        imageStyle.cornerRadiusRatio = nil
        imageStyle.border.isVisible = true

        let borderColor = UIColor(hex: "0x282828")!
        let borderWidth: CGFloat = 3

        imageStyle.border.liveUnreadState.width = borderWidth
        imageStyle.border.liveUnreadState.color = borderColor

        imageStyle.border.liveReadState.width = borderWidth
        imageStyle.border.liveReadState.color = borderColor

        imageStyle.border.unreadState.width = borderWidth
        imageStyle.border.unreadState.color = borderColor

        imageStyle.border.readState.width = borderWidth
        imageStyle.border.readState.color = borderColor

        let sideMargin: CGFloat = 10
        imageStyle.insets = .init(top: sideMargin, leading: sideMargin, bottom: sideMargin, trailing: sideMargin)
    }

    // for more information see https://dev.wsc-sports.com/docs/ios-blaze-widget-item-status-indicator-style
    private func setMyCustomStatusIndicatorStyle(for statusIndicatorStyle: inout BlazeWidgetItemStatusIndicatorStyle) {
        statusIndicatorStyle.isVisible = true
        statusIndicatorStyle.position.xPosition = .centerX(offset: 0)
        statusIndicatorStyle.position.yPosition = .topToTop(offset: 8)

        let text = "94:85"
        let backgroundColor = UIColor(hex: "0x00B27C")!
        let borderColor = UIColor(hex: "0xCFFFC2")!
        let borderWidth: CGFloat = 1
        let cornerRadius: CGFloat = 8
        let textSize: CGFloat = 11


        statusIndicatorStyle.liveUnreadState.isVisible = true
        statusIndicatorStyle.liveUnreadState.backgroundColor = backgroundColor
        statusIndicatorStyle.liveUnreadState.text = text
        statusIndicatorStyle.liveUnreadState.textStyle.font = .systemFont(ofSize: textSize)
        statusIndicatorStyle.liveUnreadState.cornerRadius = cornerRadius
        statusIndicatorStyle.liveUnreadState.cornerRadiusRatio = nil
        statusIndicatorStyle.liveUnreadState.borderColor = borderColor
        statusIndicatorStyle.liveUnreadState.borderWidth = borderWidth

        statusIndicatorStyle.liveReadState.isVisible = true
        statusIndicatorStyle.liveReadState.backgroundColor = backgroundColor
        statusIndicatorStyle.liveReadState.text = text
        statusIndicatorStyle.liveReadState.textStyle.font = .systemFont(ofSize: textSize)
        statusIndicatorStyle.liveReadState.cornerRadius = cornerRadius
        statusIndicatorStyle.liveReadState.cornerRadiusRatio = nil
        statusIndicatorStyle.liveReadState.borderColor = borderColor
        statusIndicatorStyle.liveReadState.borderWidth = borderWidth

        statusIndicatorStyle.unreadState.isVisible = true
        statusIndicatorStyle.unreadState.backgroundColor = backgroundColor
        statusIndicatorStyle.unreadState.text = text
        statusIndicatorStyle.unreadState.textStyle.font = .systemFont(ofSize: textSize)
        statusIndicatorStyle.unreadState.cornerRadius = cornerRadius
        statusIndicatorStyle.unreadState.cornerRadiusRatio = nil
        statusIndicatorStyle.unreadState.borderColor = borderColor
        statusIndicatorStyle.unreadState.borderWidth = borderWidth

        statusIndicatorStyle.readState.isVisible = true
        statusIndicatorStyle.readState.backgroundColor = backgroundColor
        statusIndicatorStyle.readState.text = text
        statusIndicatorStyle.readState.textStyle.font = .systemFont(ofSize: textSize)
        statusIndicatorStyle.readState.cornerRadius = cornerRadius
        statusIndicatorStyle.readState.cornerRadiusRatio = nil
        statusIndicatorStyle.readState.borderColor = borderColor
        statusIndicatorStyle.readState.borderWidth = borderWidth
    }

    // for more information see https://dev.wsc-sports.com/docs/ios-blaze-widget-item-title-style
    private func setMyCustomTitleStyle(for titleStyle: inout BlazeWidgetItemTitleStyle) {
        titleStyle.isVisible = true
        titleStyle.position.xPosition = .leadingToLeading(offset: 0)
        titleStyle.position.yPosition = .bottomToBottom(offset: 0)
        titleStyle.insets.bottom = 4
        titleStyle.insets.leading = 10

        let textColor = UIColor(hex: "0xA7C7FF")!
        let font = UIFont.italicSystemFont(ofSize: 14)

        titleStyle.readState.font = font
        titleStyle.readState.textColor = textColor
        titleStyle.readState.numberOfLines = 2

        titleStyle.unreadState.font = font
        titleStyle.unreadState.textColor = textColor
        titleStyle.unreadState.numberOfLines = 2
    }

    // for more information see https://dev.wsc-sports.com/docs/blazewidgetitembadgestyle#/
    private func setMyCustomBadgeStyle(for badgeStyle: inout BlazeWidgetItemBadgeStyle) {
        badgeStyle.isVisible = true
        badgeStyle.position.xPosition = .trailingToTrailing(offset: -3)
        badgeStyle.position.yPosition = .topToTop(offset: 3)

        let image = UIImage(named: "flag_us")
        let borderColor: UIColor = .white
        let borderWidth: CGFloat = 1
        let size: CGFloat = 30

        // In order to see the border we need to set the padding to the same value as the border width.
        badgeStyle.insets = .init(
            top: borderWidth,
            leading: borderWidth,
            bottom: borderWidth,
            trailing: borderWidth
        )
        
        badgeStyle.unreadState.backgroundImage = image
        badgeStyle.unreadState.width = size
        badgeStyle.unreadState.height = size
        badgeStyle.unreadState.borderColor = borderColor
        badgeStyle.unreadState.borderWidth = borderWidth

        badgeStyle.readState.backgroundImage = image
        badgeStyle.readState.width = size
        badgeStyle.readState.height = size
        badgeStyle.readState.borderColor = borderColor
        badgeStyle.readState.borderWidth = borderWidth

        badgeStyle.liveUnreadState.backgroundImage = image
        badgeStyle.liveUnreadState.width = size
        badgeStyle.liveUnreadState.height = size
        badgeStyle.liveUnreadState.borderColor = borderColor
        badgeStyle.liveUnreadState.borderWidth = borderWidth

        badgeStyle.liveReadState.backgroundImage = image
        badgeStyle.liveReadState.width = size
        badgeStyle.liveReadState.height = size
        badgeStyle.liveReadState.borderColor = borderColor
        badgeStyle.liveReadState.borderWidth = borderWidth
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

    private func getBlazeWidgetItemStyleOverrides(newWidgetLayout: BlazeWidgetLayout) -> BlazeWidgetItemStyleOverrides {
        let borderColor = UIColor(hex: "0x8E1616")!
        let badgeBorderColor = UIColor.white
        let badgeImage = UIImage(named: "flag_es")
        let badgeSize: CGFloat = 30
        let badgeBorderWidth: CGFloat = 1
        let statusBackgroundColor = UIColor(hex: "0x8E1616")!
        let statusBorderColor = UIColor(hex: "0xFF6161")!
        let statusCornerRadius: CGFloat = 4
        let statusBorderWidth: CGFloat = 1
        let statusText = "Breaking"
        let imageBorderWidth = 3.0

        var imageBorder = newWidgetLayout.widgetItemStyle.image.border
        
        imageBorder.isVisible = true
        imageBorder.readState.color = borderColor
        imageBorder.unreadState.color = borderColor
        imageBorder.liveReadState.color = borderColor
        imageBorder.liveUnreadState.color = borderColor
        
        imageBorder.readState.width = imageBorderWidth
        imageBorder.unreadState.width = imageBorderWidth
        imageBorder.liveReadState.width = imageBorderWidth
        imageBorder.liveUnreadState.width = imageBorderWidth

        var badge = newWidgetLayout.widgetItemStyle.badge
        badge.isVisible = true
        badge.position.xPosition = .trailingToTrailing(offset: -5)
        badge.position.yPosition = .topToTop(offset: 5)

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

        var statusIndicator = newWidgetLayout.widgetItemStyle.statusIndicator
        statusIndicator.position.xPosition = .trailingToTrailing(offset: -8)
        statusIndicator.position.yPosition = .bottomToBottom(offset: -8)

        statusIndicator.unreadState.isVisible = true
        statusIndicator.unreadState.backgroundColor = statusBackgroundColor
        statusIndicator.unreadState.text = statusText
        statusIndicator.unreadState.cornerRadius = statusCornerRadius
        statusIndicator.unreadState.cornerRadiusRatio = nil
        statusIndicator.unreadState.borderColor = statusBorderColor
        statusIndicator.unreadState.borderWidth = statusBorderWidth

        statusIndicator.readState.isVisible = true
        statusIndicator.readState.backgroundColor = statusBackgroundColor
        statusIndicator.readState.text = statusText
        statusIndicator.readState.cornerRadius = statusCornerRadius
        statusIndicator.readState.cornerRadiusRatio = nil
        statusIndicator.readState.borderColor = statusBorderColor
        statusIndicator.readState.borderWidth = statusBorderWidth

        statusIndicator.liveUnreadState.isVisible = true
        statusIndicator.liveUnreadState.backgroundColor = statusBackgroundColor
        statusIndicator.liveUnreadState.text = statusText
        statusIndicator.liveUnreadState.cornerRadius = statusCornerRadius
        statusIndicator.liveUnreadState.cornerRadiusRatio = nil
        statusIndicator.liveUnreadState.borderColor = statusBorderColor
        statusIndicator.liveUnreadState.borderWidth = statusBorderWidth

        statusIndicator.liveReadState.isVisible = true
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
