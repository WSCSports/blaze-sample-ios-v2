//
//  FollowEntitiesSwiftUIViewModel.swift
//  blaze-sample-ios-v2
//

import BlazeSDK
import SwiftUI

///
/// Owns the tabs-backed Moments widget's state for `FollowEntitiesSwiftUIView`, mirroring
/// `FollowEntitiesViewController` (the UIKit variant) — see that file for the full behavior
/// rationale behind the follow-refresh choreography below.
///
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

    /// Note: `onPlayerDidAppear`/`onPlayerDidDismiss` fire on every tab switch inside the
    /// fullscreen player (the previous tab is "dismissed", the next one "appears"), not only
    /// when the player itself opens or closes — don't use them to track the player's presence.
    ///
    /// `isYourPicksTabActive` tracks whether "Your Picks" is the tab the user is currently
    /// watching — the active tab must never be reloaded mid-playback. A follow change made
    /// while watching "Your Picks" is instead applied the moment the user switches to another
    /// tab, so returning to it within the same player session already shows fresh content.
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

    /// SwiftUI's equivalent of `viewDidAppear` — the screen isn't covered by the fullscreen
    /// tabs player anymore, so any deferred rebuild can safely run now.
    func viewDidAppear() {
        isViewVisible = true

        // Unlike the UIKit variant (which loads the widget right after embedding it in
        // `viewDidLoad`), `BlazeSwiftUIMomentsRowWidgetView` only wires up its reload
        // subscription once SwiftUI actually builds it — so the first load has to be
        // triggered from here, the first point at which that's guaranteed to have happened.
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

    /// SwiftUI's equivalent of `viewWillDisappear` — the fullscreen tabs player is about to
    /// cover this screen.
    func viewWillDisappear() {
        isViewVisible = false
    }

    /// Builds a tabs-backed moments widget (Trending / For You / Your Picks) that demonstrates
    /// personalized content via BlazeSDK Follow Entities.
    ///
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

    /// Applies a follow change twofold, mirroring `FollowEntitiesViewController`:
    ///
    /// While the feed is visible, the widget is simply rebuilt with the fresh tabs.
    ///
    /// While the fullscreen player is open, the new "Your Picks" data source is swapped in via
    /// `upsertTabs` — a data-source-only upsert doesn't touch the tabs UI or playback — and
    /// non-active tabs refetch right away (`reloadNonActiveTabs`), so switching to "Your Picks"
    /// within the same player session already shows fresh content. The active tab is never
    /// reloaded mid-playback: a change made while watching "Your Picks" itself is applied on
    /// the next switch to another tab (see `onTabSelected`). The full widget rebuild on return
    /// to the feed (`viewDidAppear`) stays as the catch-all — it covers the still-active tab
    /// and re-adds the tab in case the SDK removed it after it loaded empty.
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

    /// Full refresh of the tabs widget — used when the feed is visible or after the player closes.
    private func reloadMomentsFollowTabsWidget() {
        // A full refresh rebuilds every tab fresh, so no in-session reload is owed anymore.
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

    /// "Your Picks" surfaces moments labeled with any of the followed entity ids or the general
    /// highlights label. `labelsPriority` ranks the followed entities first (most recently followed
    /// on top), so personalized content leads and general highlights fill in whenever it runs short.
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

    /// Shows the follow button in the moments player. The entity offered to follow
    /// is resolved in a fallback order: player -> team -> property.
    /// The followed state is highlighted so it clearly stands out from the unfollowed one.
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
