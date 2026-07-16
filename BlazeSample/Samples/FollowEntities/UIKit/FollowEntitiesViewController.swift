//
//  FollowEntitiesViewController.swift
//  blaze-sample-ios-v2
//

import UIKit
import BlazeSDK

///
/// `FollowEntitiesViewController` demonstrates the BlazeSDK Follow Entities feature end to end,
/// via a single tabs-backed Moments widget (Trending / For You / Your Picks). "Your Picks" is
/// personalized from the entities the user follows in the moments player (see `Samples/FollowEntities/Follow/`).
///

class FollowEntitiesViewController: UIViewController {

    private enum FollowTabs {
        static let containerSourceId = "follow-entities-moments-tabs-id"
        static let trendingId = "follow-entities-tab-trending"
        static let forYouId = "follow-entities-tab-for-you"
        static let yourPicksId = "follow-entities-tab-your-picks"
    }

    private let contentView = MixedWidgetsView()
    private let viewModel = WidgetsViewModel(widgetType: .mixed)

    private var momentsRowWidgetView: BlazeMomentsWidgetRowView?
    private var momentsTabsContainer: BlazeMomentsPlayerContainerTabs?
    private var yourPicksTab: BlazeMomentsContainerTabItem?

    private var hasPendingWidgetReinit = false
    private var hasPendingYourPicksReload = false
    private var isYourPicksTabActive = false
    private var isViewVisible = false

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

    override func loadView() {
        self.view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initWidget()
    }

    /// The fullscreen tabs player is presented modally (`.fullScreen`) over this screen, so
    /// returning from it lands here — the place to apply a widget rebuild deferred while the
    /// player was covering the feed (mirrors the Android sample's `onResume`).
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewVisible = true
        if hasPendingWidgetReinit {
            hasPendingWidgetReinit = false
            reloadMomentsFollowTabsWidget()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isViewVisible = false
    }

    /// Builds a tabs-backed moments widget (Trending / For You / Your Picks) that demonstrates
    /// personalized content via BlazeSDK Follow Entities.
    ///
    /// The widget row uses the **first tab's** data source for thumbnails — keep a label with
    /// content there.
    ///
    /// Follow changes swap the "Your Picks" data source and refresh non-active tabs right away,
    /// even while the player is open; the widget row itself is rebuilt once the user returns
    /// to the feed (see `handleFollowChanged`).
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

        let widget = BlazeMomentsWidgetRowView(layout: viewModel.momentsRowBaseLayout, tabsContainer: tabsContainer)
        widget.widgetIdentifier = "follow-entities-moments-tabs-row-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        self.momentsRowWidgetView = widget

        let section = WidgetSectionView(height: 300, title: "Moments Follow Tabs")
        widget.embedInView(section.containerView)
        widget.reloadData(progressType: .skeleton)
        contentView.stackView.addArrangedSubview(section)

        SampleFollowEntitiesManager.shared.onFollowChanged = { [weak self] in
            self?.handleFollowChanged()
        }
    }

    /// Applies a follow change twofold, mirroring the Android sample:
    ///
    /// While the feed is visible, the widget row is simply rebuilt with the fresh tabs.
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

    /// Full refresh of the tabs widget row — used when the feed is visible or after the player closes.
    private func reloadMomentsFollowTabsWidget() {
        // A full refresh rebuilds every tab fresh, so no in-session reload is owed anymore.
        hasPendingYourPicksReload = false
        let yourPicksTab = makeYourPicksTab()
        self.yourPicksTab = yourPicksTab
        momentsTabsContainer?.upsertTabs([yourPicksTab])
        momentsRowWidgetView?.reloadData(progressType: .skeleton)
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
