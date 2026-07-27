//
//  FollowTabsConfiguration.swift
//  blaze-sample-ios-v2
//

import UIKit
import BlazeSDK

/// Shared tab ids and builders for the Moments Follow Tabs example (Trending / For You /
/// Your Picks), used by both `FollowEntitiesViewController` (UIKit) and
/// `FollowEntitiesSwiftUIViewModel` (SwiftUI) so the tab setup stays identical.
enum FollowTabsConfiguration {
    static let trendingTabId = "trending-tab"
    static let forYouTabId = "for-you-tab"
    static let yourPicksTabId = "your-picks-tab"

    /// The SDK reports tab callbacks (`onPlayerDidAppear`/`onTabSelected`) with a sourceId in
    /// the "{containerSourceId}_{containerId}" format.
    static func yourPicksSourceId(containerSourceId: String) -> String {
        "\(containerSourceId)_\(yourPicksTabId)"
    }

    /// Ranks followed entities first (most recently followed on top); general highlights fill
    /// in whenever personalized content runs short.
    static func makeYourPicksTab() -> BlazeMomentsContainerTabItem {
        let labels = SampleFollowEntitiesManager.shared.recentFollowedEntityIds() + [ConfigManager.momentContainerLabel1]

        return BlazeMomentsContainerTabItem(
            containerId: yourPicksTabId,
            title: "Your Picks",
            dataSource: .labels(
                .atLeastOneOf(labels),
                labelsPriority: labels.map { BlazeWidgetLabel.singleLabel($0) },
                orderType: .recentlyUpdatedFirst
            )
        )
    }

    /// The widget uses the **first tab's** data source for thumbnails — keep a label with
    /// content there.
    static func makeTabs(yourPicksTab: BlazeMomentsContainerTabItem) -> [BlazeMomentsContainerTabItem] {
        [
            BlazeMomentsContainerTabItem(
                containerId: trendingTabId,
                title: "Trending",
                dataSource: .labels(.singleLabel(ConfigManager.momentContainerLabel1))
            ),
            BlazeMomentsContainerTabItem(
                containerId: forYouTabId,
                title: "For You",
                dataSource: .labels(.singleLabel(ConfigManager.momentContainerLabel2))
            ),
            yourPicksTab
        ]
    }

    /// Entity offered to follow is resolved player -> team -> property.
    static func makePlayerStyle() -> BlazeMomentsPlayerStyle {
        let wscAccentColor = UIColor(hex: "E5FF00") ?? .systemYellow
        var style = Blaze.shared.getDefaultMomentsPlayerStyle()
        style.followEntity.isVisible = true
        style.followEntity.entityType = .player(
            fallbackType: .team(
                fallbackType: .property(
                    fallbackType: nil
                )
            )
        )
        style.followEntity.followState.avatar.borderColor = wscAccentColor
        style.followEntity.followState.chip.backgroundColor = wscAccentColor
        style.followEntity.followState.chip.iconColor = .black
        return style
    }
}
