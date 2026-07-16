//
//  MixedWidgetsViewController.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 23/06/2025.
//

import UIKit
import BlazeSDK

///
/// MixedWidgetsViewController displays a mixed feed of Blaze widgets: a stories row, a
/// personalized "Moments Follow Tabs" row, a videos row, and a stories grid.
/// It manages reloading widget data with pull-to-refresh.
///
/// The "Moments Follow Tabs" row is the sample's personalized-experience example: a tabs-backed
/// moments widget whose "Your Picks" tab is driven by the BlazeSDK Follow Entities feature
/// (see `Samples/widgets/Follow/`).
///

class MixedWidgetsViewController: UIViewController {

    private enum FollowTabs {
        static let containerSourceId = "mixed-widgets-moments-follow-tabs-id"
        static let trendingId = "moments-follow-tabs-trending"
        static let forYouId = "moments-follow-tabs-for-you"
        static let yourPicksId = "moments-follow-tabs-your-picks"
    }

    private let contentView = MixedWidgetsView()
    private let viewModel = WidgetsViewModel(widgetType: .mixed)
    
    private var storiesRowWidgetView: BlazeStoriesWidgetRowView?
    private var storiesGridWidgetView: BlazeStoriesWidgetGridView?
    private var momentsRowWidgetView: BlazeMomentsWidgetRowView?
    private var videosRowWidgetView: BlazeVideosWidgetRowView?
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

        initWidgets()

        contentView.refreshControl.addTarget(self, action: #selector(pullToRefreshTriggered), for: .valueChanged)

        viewModel.onRefreshCompleted = { [weak self] in
            self?.contentView.refreshControl.endRefreshing()
        }
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
    
    func initWidgets() {
        initStoriesRowWidget()
        initMomentsFollowTabsRowWidget()
        initVideosRowWidget()
        initStoriesGridWidget()
    }
    
    func initStoriesRowWidget() {
        let widgetLayout = viewModel.storiesRowBaseLayout
        
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(ConfigManager.storiesRowLabel)
        )
        
        let widget = BlazeStoriesWidgetRowView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = "mixed-widgets-stories-row-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        self.storiesRowWidgetView = widget

        let section = WidgetSectionView.init(height: 160, title: "Stories row widget")
        widget.embedInView(section.containerView)
        widget.reloadData(progressType: .skeleton)
        contentView.stackView.addArrangedSubview(section)
    }
    
    func initStoriesGridWidget() {
        let widgetLayout = viewModel.storiesGridBaseLayout
        
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(ConfigManager.storiesGridLabel)
        )
        
        let widget = BlazeStoriesWidgetGridView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = "mixed-widgets-stories-grid-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        widget.isEmbededInScrollView = true
        self.storiesGridWidgetView = widget
        
        let section = WidgetSectionView.init(title: "Stories grid widget")
        widget.embedInView(section.containerView)
        widget.reloadData(progressType: .skeleton)
        contentView.stackView.addArrangedSubview(section)
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
    func initMomentsFollowTabsRowWidget() {
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
        widget.widgetIdentifier = "mixed-widgets-moments-follow-tabs-row-id"
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

    func initVideosRowWidget() {
        let widgetLayout = viewModel.videosRowBaseSingleItemLayout
        
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(ConfigManager.videosRowLabel)
        )
        
        let widget = BlazeVideosWidgetRowView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = "mixed-widgets-videos-row-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        self.videosRowWidgetView = widget
        
        let section = WidgetSectionView.init(height: 230, title: "Videos row widget")
        widget.embedInView(section.containerView)
        widget.reloadData(progressType: .skeleton)
        contentView.stackView.addArrangedSubview(section)
    }

    @objc private func pullToRefreshTriggered() {
        [momentsRowWidgetView, storiesGridWidgetView, storiesRowWidgetView, videosRowWidgetView]
            .forEach { $0?.reloadData(progressType: .skeleton) }

        // Example: use the tabs container when the player is open to navigate back to the first tab on refresh.
        // momentsTabsContainer is non-nil only after initMomentsFollowTabsRowWidget() is called.
        momentsTabsContainer?.selectTab(at: 0, animated: true)
    }
}
