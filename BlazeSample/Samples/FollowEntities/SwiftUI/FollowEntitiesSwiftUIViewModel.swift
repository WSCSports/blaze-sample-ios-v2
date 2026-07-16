//
//  FollowEntitiesSwiftUIViewModel.swift
//  blaze-sample-ios-v2
//

import BlazeSDK
import SwiftUI

/// Owns the tabs-backed Moments widget's state for `FollowEntitiesSwiftUIView`, mirroring
/// `FollowEntitiesViewController` (the UIKit variant).
final class FollowEntitiesSwiftUIViewModel: ObservableObject {

    private enum FollowTabs {
        static let containerSourceId = "follow-entities-swiftui-moments-tabs-id"
        static let trendingId = "follow-entities-swiftui-tab-trending"
        static let forYouId = "follow-entities-swiftui-tab-for-you"
        static let yourPicksId = "follow-entities-swiftui-tab-your-picks"
    }

    @Published var momentsTabsViewModel: BlazeSwiftUIMomentsWidgetViewModel!

    private var momentsTabsContainer: BlazeMomentsPlayerContainerTabs!
    private var yourPicksTab: BlazeMomentsContainerTabItem!

    private var hasPendingWidgetReinit = false
    private var hasPendingYourPicksReload = false
    private var isYourPicksTabActive = false
    private var isViewVisible = false
    private var hasLoadedInitialData = false

    /// `onPlayerDidAppear`/`onPlayerDidDismiss` fire on every tab switch, not just when the
    /// player opens/closes — track the active tab via `isYourPicksTabActive` instead, so it's
    /// never reloaded mid-playback.
    private lazy var momentsContainerTabsDelegate = BlazePlayerContainerTabsDelegate(
        onPlayerDidAppear: { [weak self] params in
            self?.isYourPicksTabActive = params.sourceId?.hasSuffix(FollowTabs.yourPicksId) == true
        },
        onTabSelected: { [weak self] params in
            guard let self else { return }
            self.isYourPicksTabActive = params.sourceId.hasSuffix(FollowTabs.yourPicksId)
            if !self.isYourPicksTabActive, self.hasPendingYourPicksReload {
                self.hasPendingYourPicksReload = false
                self.momentsTabsContainer?.reloadNonActiveTabs()
            }
        }
    )

    init() {
        initWidget()
    }

    func viewDidAppear() {
        isViewVisible = true

        // `BlazeSwiftUIMomentsRowWidgetView` only wires up its reload subscription once
        // SwiftUI builds it, so the first load is triggered here rather than in init().
        guard hasLoadedInitialData else {
            hasLoadedInitialData = true
            momentsTabsViewModel.reloadData(progressType: .skeleton)
            return
        }

        if hasPendingWidgetReinit {
            hasPendingWidgetReinit = false
            reloadMomentsFollowTabsWidget()
        }
    }

    func viewWillDisappear() {
        isViewVisible = false
    }

    /// The widget uses the **first tab's** data source for thumbnails — keep a label with
    /// content there.
    private func initWidget() {
        let yourPicksTab = makeYourPicksTab()
        self.yourPicksTab = yourPicksTab

        let tabsContainer = BlazeMomentsPlayerContainerTabs(
            tabs: makeFollowTabs(yourPicksTab: yourPicksTab),
            playerStyle: makeFollowMomentsPlayerStyle(),
            tabsStyle: .base(),
            containerTabsDelegate: momentsContainerTabsDelegate,
            containerSourceId: FollowTabs.containerSourceId
        )
        momentsTabsContainer = tabsContainer

        momentsTabsViewModel = BlazeSwiftUIMomentsWidgetViewModel(
            tabsWidgetConfiguration: BlazeSwiftUIMomentsTabsWidgetConfiguration(
                layout: .Presets.MomentsWidget.Row.verticalAnimatedThumbnailsRectangles,
                tabsContainer: tabsContainer
            )
        )

        SampleFollowEntitiesManager.shared.onFollowChanged = { [weak self] in
            self?.handleFollowChanged()
        }
    }

    /// While the feed is visible, just rebuild the widget. While the fullscreen player is
    /// open, swap the "Your Picks" data source via `upsertTabs` and refresh non-active tabs
    /// right away — the active tab is never reloaded mid-playback, it catches up on the next
    /// tab switch or once the feed is visible again.
    private func handleFollowChanged() {
        if isViewVisible {
            reloadMomentsFollowTabsWidget()
            return
        }

        let yourPicksTab = makeYourPicksTab()
        self.yourPicksTab = yourPicksTab
        momentsTabsContainer?.upsertTabs([yourPicksTab])

        if isYourPicksTabActive {
            hasPendingYourPicksReload = true
        } else {
            momentsTabsContainer?.reloadNonActiveTabs()
        }
        hasPendingWidgetReinit = true
    }

    private func reloadMomentsFollowTabsWidget() {
        hasPendingYourPicksReload = false
        let yourPicksTab = makeYourPicksTab()
        self.yourPicksTab = yourPicksTab
        momentsTabsContainer?.upsertTabs([yourPicksTab])
        momentsTabsViewModel.reloadData(progressType: .skeleton)
    }

    private func makeFollowTabs(yourPicksTab: BlazeMomentsContainerTabItem) -> [BlazeMomentsContainerTabItem] {
        [
            BlazeMomentsContainerTabItem(
                containerId: FollowTabs.trendingId,
                title: "Trending",
                dataSource: .labels(.singleLabel(ConfigManager.momentContainerLabel1))
            ),
            BlazeMomentsContainerTabItem(
                containerId: FollowTabs.forYouId,
                title: "For You",
                dataSource: .labels(.singleLabel(ConfigManager.momentContainerLabel2))
            ),
            yourPicksTab
        ]
    }

    /// Ranks followed entities first (most recently followed on top); general highlights fill
    /// in whenever personalized content runs short.
    private func makeYourPicksTab() -> BlazeMomentsContainerTabItem {
        let labels = SampleFollowEntitiesManager.shared.recentFollowedEntityIds() + [ConfigManager.momentContainerLabel1]

        return BlazeMomentsContainerTabItem(
            containerId: FollowTabs.yourPicksId,
            title: "Your Picks",
            dataSource: .labels(
                .atLeastOneOf(labels),
                labelsPriority: labels.map { BlazeWidgetLabel.singleLabel($0) },
                orderType: .recentlyUpdatedFirst
            )
        )
    }

    /// Entity offered to follow is resolved player -> team -> property.
    private func makeFollowMomentsPlayerStyle() -> BlazeMomentsPlayerStyle {
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
