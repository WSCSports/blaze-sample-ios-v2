//
//  LiveVideoRowViewController.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 16/07/2026.
//

import UIKit
import BlazeSDK
import SwiftUI

///
/// `LiveVideoRowViewController` is a view controller that displays a horizontal row of the Videos widget
/// filtered to live/upcoming/ended stream content via `videosFilterParams`, with a customization example
/// for the per-stream-state status indicator (the "LIVE"/"UPCOMING"/"ENDED" badge).
/// For more information on `BlazeVideosWidgetRowView`, see:
/// https://dev.wsc-sports.com/docs/ios-widgets#/videos-row
///

class LiveVideoRowViewController: BaseWidgetEditOptionsViewController {

    private var videosWidget: BlazeVideosWidgetRowView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setContentViewFixedHeight(230)
    }

    override init(viewModel: WidgetsViewModel = WidgetsViewModel(widgetType: .liveVideoRow)) {
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
        // advancedOrderType takes priority over orderType, surfacing live streams ahead of
        // upcoming/ended/VOD content regardless of the base order type.
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(viewModel.widgetDataState.labelName),
            orderType: viewModel.widgetDataState.orderType,
            advancedOrderType: .liveFirst
        )

        let widget = BlazeVideosWidgetRowView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = viewModel.currentWidgetType.rawValue
        widget.widgetDelegate = viewModel.widgetDelegate
        // Without this, only VOD content is returned - streams are opted-in explicitly.
        widget.videosFilterParams = viewModel.liveVideoFilterParams
        widget.videosPlayerStyle = .base()
        widget.reloadData(progressType: .skeleton)
        widget.embedInView(contentView)
        self.widgetView = widget
        self.videosWidget = widget
    }

    override func onNewWidgetLayoutState(_ styleState: WidgetLayoutStyleState) {
        var layout = viewModel.getWidgetLayoutBasePreset()

        if styleState.isCustomAppearance {
            setMyCustomImageStyle(for: &layout.widgetItemStyle.image)
        }

        var playerStyle = BlazeVideosPlayerStyle.base()
        if styleState.isCustomStatusIndicator {
            setMyCustomStatusIndicatorStyle(for: &layout.widgetItemStyle.statusIndicator)
            setMyCustomPlayerStatusIndicatorStyle(for: &playerStyle.statusIndicator)
        }
        videosWidget?.videosPlayerStyle = playerStyle

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
        imageStyle.cornerRadius = 12
        imageStyle.cornerRadiusRatio = nil
        imageStyle.border.isVisible = true

        let borderColor = UIColor(hex: "0xFF3131")!
        let borderWidth: CGFloat = 2

        imageStyle.border.unreadState.width = borderWidth
        imageStyle.border.unreadState.color = borderColor
        imageStyle.border.readState.width = borderWidth
        imageStyle.border.readState.color = borderColor
        imageStyle.border.liveUnreadState.width = borderWidth
        imageStyle.border.liveUnreadState.color = borderColor
        imageStyle.border.liveReadState.width = borderWidth
        imageStyle.border.liveReadState.color = borderColor
    }

    // Customizes the per-stream-state badge (the "LIVE"/"UPCOMING"/"ENDED" chip), rather than
    // the generic read/unread indicator - this is what actually reflects a video's stream status.
    // for more information see https://dev.wsc-sports.com/docs/ios-blaze-widget-item-status-indicator-style
    private func setMyCustomStatusIndicatorStyle(for statusIndicatorStyle: inout BlazeWidgetItemStatusIndicatorStyle) {
        statusIndicatorStyle.isVisible = true
        statusIndicatorStyle.position.xPosition = .leadingToLeading(offset: 8)
        statusIndicatorStyle.position.yPosition = .topToTop(offset: 8)
        statusIndicatorStyle.insets = .init(top: 0, leading: 8, bottom: 0, trailing: 12)

        let textSize: CGFloat = 12
        let cornerRadius: CGFloat = 8

        statusIndicatorStyle.streamStates.liveStreamState.backgroundColor = UIColor(hex: "0xFF3131")!
        statusIndicatorStyle.streamStates.liveStreamState.textStyle.textColor = .white
        statusIndicatorStyle.streamStates.liveStreamState.textStyle.font = .boldSystemFont(ofSize: textSize)
        statusIndicatorStyle.streamStates.liveStreamState.cornerRadius = cornerRadius

        statusIndicatorStyle.streamStates.upcomingStreamState.backgroundColor = UIColor(hex: "0x3357FF")!
        statusIndicatorStyle.streamStates.upcomingStreamState.textStyle.textColor = .white
        statusIndicatorStyle.streamStates.upcomingStreamState.textStyle.font = .systemFont(ofSize: textSize)
        statusIndicatorStyle.streamStates.upcomingStreamState.cornerRadius = cornerRadius

        statusIndicatorStyle.streamStates.endedStreamState.backgroundColor = UIColor(hex: "0x888888")!
        statusIndicatorStyle.streamStates.endedStreamState.textStyle.textColor = .white
        statusIndicatorStyle.streamStates.endedStreamState.textStyle.font = .systemFont(ofSize: textSize)
        statusIndicatorStyle.streamStates.endedStreamState.cornerRadius = cornerRadius
    }

    // Mirrors the widget-cell's per-stream-state colors onto the full-screen player's own
    // LIVE/UPCOMING/ENDED badge, so the customization carries through from feed to player.
    // for more information see https://dev.wsc-sports.com/docs/ios-blaze-video-player-status-indicator-style
    private func setMyCustomPlayerStatusIndicatorStyle(for statusIndicatorStyle: inout BlazeVideosPlayerStatusIndicatorStyle) {
        let textSize: CGFloat = 12
        let cornerRadius: CGFloat = 8

        statusIndicatorStyle.streamStates.liveStreamState.backgroundColor = UIColor(hex: "0xFF3131")!
        statusIndicatorStyle.streamStates.liveStreamState.textStyle.textColor = .white
        statusIndicatorStyle.streamStates.liveStreamState.textStyle.font = .boldSystemFont(ofSize: textSize)
        statusIndicatorStyle.streamStates.liveStreamState.cornerRadius = cornerRadius

        statusIndicatorStyle.streamStates.upcomingStreamState.backgroundColor = UIColor(hex: "0x3357FF")!
        statusIndicatorStyle.streamStates.upcomingStreamState.textStyle.textColor = .white
        statusIndicatorStyle.streamStates.upcomingStreamState.textStyle.font = .systemFont(ofSize: textSize)
        statusIndicatorStyle.streamStates.upcomingStreamState.cornerRadius = cornerRadius

        statusIndicatorStyle.streamStates.endedStreamState.backgroundColor = UIColor(hex: "0x888888")!
        statusIndicatorStyle.streamStates.endedStreamState.textStyle.textColor = .white
        statusIndicatorStyle.streamStates.endedStreamState.textStyle.font = .systemFont(ofSize: textSize)
        statusIndicatorStyle.streamStates.endedStreamState.cornerRadius = cornerRadius
    }

    // for more information see https://dev.wsc-sports.com/docs/ios-blaze-widget-item-title-style
    private func setMyCustomTitleStyle(for titleStyle: inout BlazeWidgetItemTitleStyle) {
        titleStyle.isVisible = true
        titleStyle.position.xPosition = .leadingToLeading(offset: 4)
        titleStyle.position.yPosition = .bottomToBottom(offset: -12)

        let textColor = UIColor.white
        let font = UIFont.boldSystemFont(ofSize: 15)

        titleStyle.readState.font = font
        titleStyle.readState.textColor = textColor
        titleStyle.readState.numberOfLines = 1

        titleStyle.unreadState.font = font
        titleStyle.unreadState.textColor = textColor
        titleStyle.unreadState.numberOfLines = 1
    }

    // for more information see https://dev.wsc-sports.com/docs/blazewidgetitembadgestyle#/
    private func setMyCustomBadgeStyle(for badgeStyle: inout BlazeWidgetItemBadgeStyle) {
        let text = "HD"
        let backgroundColor = UIColor(hex: "0xFF3131")!
        let textColor = UIColor.white
        let textSize: CGFloat = 12
        let size: CGFloat = 22

        badgeStyle.isVisible = true
        badgeStyle.position.xPosition = .leadingToLeading(offset: 8)
        badgeStyle.position.yPosition = .topToTop(offset: 30)

        badgeStyle.unreadState.text = text
        badgeStyle.unreadState.textStyle.font = .boldSystemFont(ofSize: textSize)
        badgeStyle.unreadState.textStyle.textColor = textColor
        badgeStyle.unreadState.backgroundColor = backgroundColor
        badgeStyle.unreadState.width = size
        badgeStyle.unreadState.height = size

        badgeStyle.readState = badgeStyle.unreadState
        badgeStyle.liveUnreadState = badgeStyle.unreadState
        badgeStyle.liveReadState = badgeStyle.unreadState
    }

    // Example of setting custom styles for a specific widget item by its game ID.
    // We get the mapping key and value from the BE, inside the item object entities field.
    // For more information see https://dev.wsc-sports.com/docs/blazewidgetitemcustommapping#/
    private func setOverrideStylesByGameId(widgetLayout: BlazeWidgetLayout) {
        let mappingKey = BlazeExtraInfoKeyPreset.gameId
        let mappingValue = "2445381"
        let mapping = BlazeWidgetItemCustomMapping(keyPreset: mappingKey, value: mappingValue)
        let styleOverrides = getBlazeWidgetItemStyleOverrides(newWidgetLayout: widgetLayout)
        widgetView?.updateOverrideStyles(stylesPerItem: [mapping: styleOverrides], shouldUpdateUI: true)
    }

    private func getBlazeWidgetItemStyleOverrides(newWidgetLayout: BlazeWidgetLayout) -> BlazeWidgetItemStyleOverrides {
        let accentColor = UIColor(hex: "0xFFD700")!

        var imageBorder = newWidgetLayout.widgetItemStyle.image.border
        imageBorder.isVisible = true
        imageBorder.readState.color = accentColor
        imageBorder.readState.width = 3
        imageBorder.unreadState.color = accentColor
        imageBorder.unreadState.width = 3
        imageBorder.liveReadState.color = accentColor
        imageBorder.liveReadState.width = 3
        imageBorder.liveUnreadState.color = accentColor
        imageBorder.liveUnreadState.width = 3

        var statusIndicator = newWidgetLayout.widgetItemStyle.statusIndicator
        statusIndicator.streamStates.liveStreamState.backgroundColor = accentColor
        statusIndicator.streamStates.liveStreamState.textStyle.textColor = .black
        statusIndicator.streamStates.liveStreamState.text = "FEATURED LIVE"

        return BlazeWidgetItemStyleOverrides(
            statusIndicator: statusIndicator,
            imageBorder: imageBorder
        )
    }
}
