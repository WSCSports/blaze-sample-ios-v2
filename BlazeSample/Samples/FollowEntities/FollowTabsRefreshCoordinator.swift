//
//  FollowTabsRefreshCoordinator.swift
//  blaze-sample-ios-v2
//

import BlazeSDK

/// Refreshes the personalized "Your Picks" tab when the followed entities change, shared by
/// `FollowEntitiesViewController` (UIKit) and `FollowEntitiesSwiftUIViewModel` (SwiftUI) so the
/// choreography lives in one place. A follow change is applied depending on where the user is:
/// - widget visible, no player on top -> rebuild it with the fresh tabs right away;
/// - in the player on another tab -> refresh "Your Picks" in the background, rebuild on return;
/// - in the player watching "Your Picks" -> apply it once the user switches away, rebuild on return.
final class FollowTabsRefreshCoordinator {

    /// The framework-specific hook: the UIKit variant calls `widget.reloadData(progressType:)`,
    /// the SwiftUI variant calls it on its `BlazeSwiftUIMomentsWidgetViewModel`.
    private let reloadWidgetData: () -> Void
    private let yourPicksSourceId: String

    var tabsContainer: BlazeMomentsPlayerContainerTabs?
    private(set) var yourPicksTab = FollowTabsConfiguration.makeYourPicksTab()

    private var hasPendingWidgetReinit = false
    private var hasPendingYourPicksReload = false
    private var isYourPicksTabActive = false

    init(containerSourceId: String, reloadWidgetData: @escaping () -> Void) {
        self.yourPicksSourceId = FollowTabsConfiguration.yourPicksSourceId(containerSourceId: containerSourceId)
        self.reloadWidgetData = reloadWidgetData
    }

    /// `onPlayerDidAppear`/`onPlayerDidDismiss` fire on every tab switch, not just when the
    /// player opens/closes — track the active tab via `isYourPicksTabActive` instead, so it's
    /// never reloaded mid-playback.
    lazy var containerTabsDelegate = BlazePlayerContainerTabsDelegate(
        onPlayerDidAppear: { [weak self] params in
            guard let self else { return }
            self.isYourPicksTabActive = params.sourceId?.hasSuffix(self.yourPicksSourceId) == true
        },
        onTabSelected: { [weak self] params in
            guard let self else { return }
            self.isYourPicksTabActive = params.sourceId.hasSuffix(self.yourPicksSourceId)
            if !self.isYourPicksTabActive, self.hasPendingYourPicksReload {
                self.hasPendingYourPicksReload = false
                self.tabsContainer?.reloadNonActiveTabs()
            }
        }
    )

    /// Builds the initial tab set — call once, before constructing the tabs container.
    func buildInitialTabs() -> [BlazeMomentsContainerTabItem] {
        FollowTabsConfiguration.makeTabs(yourPicksTab: yourPicksTab)
    }

    /// Call whenever `SampleFollowEntitiesManager.onFollowChanged` fires.
    func handleFollowChanged(isViewVisible: Bool) {
        if isViewVisible {
            reloadWidget()
            return
        }

        yourPicksTab = FollowTabsConfiguration.makeYourPicksTab()
        tabsContainer?.upsertTabs([yourPicksTab])

        if isYourPicksTabActive {
            hasPendingYourPicksReload = true
        } else {
            tabsContainer?.reloadNonActiveTabs()
        }
        hasPendingWidgetReinit = true
    }

    /// Call from `viewDidAppear`/its SwiftUI equivalent to apply a change deferred while the
    /// fullscreen player was covering the widget.
    func viewDidAppear() {
        if hasPendingWidgetReinit {
            hasPendingWidgetReinit = false
            reloadWidget()
        }
    }

    private func reloadWidget() {
        hasPendingYourPicksReload = false
        yourPicksTab = FollowTabsConfiguration.makeYourPicksTab()
        tabsContainer?.upsertTabs([yourPicksTab])
        reloadWidgetData()
    }
}
