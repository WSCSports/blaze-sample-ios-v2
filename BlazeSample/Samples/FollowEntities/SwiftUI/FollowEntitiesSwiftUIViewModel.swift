//
//  FollowEntitiesSwiftUIViewModel.swift
//  blaze-sample-ios-v2
//

import BlazeSDK
import SwiftUI

/// Owns the tabs-backed Moments widget's state for `FollowEntitiesSwiftUIView`, mirroring
/// `FollowEntitiesViewController` (the UIKit variant). The follow-change choreography lives in
/// `FollowTabsRefreshCoordinator`; this view model only wires the widget to it.
final class FollowEntitiesSwiftUIViewModel: ObservableObject {

    private static let containerSourceId = "follow-entities-swiftui-moments-tabs-id"

    @Published var momentsTabsViewModel: BlazeSwiftUIMomentsWidgetViewModel!

    private var coordinator: FollowTabsRefreshCoordinator?
    private var isViewVisible = false
    private var hasLoadedInitialData = false

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

        coordinator?.viewDidAppear()
    }

    func viewWillDisappear() {
        isViewVisible = false
    }

    private func initWidget() {
        let coordinator = FollowTabsRefreshCoordinator(containerSourceId: Self.containerSourceId) { [weak self] in
            self?.momentsTabsViewModel.reloadData(progressType: .skeleton)
        }
        self.coordinator = coordinator

        let tabsContainer = BlazeMomentsPlayerContainerTabs(
            tabs: coordinator.buildInitialTabs(),
            playerStyle: FollowTabsConfiguration.makePlayerStyle(),
            tabsStyle: .base(),
            containerTabsDelegate: coordinator.containerTabsDelegate,
            containerSourceId: Self.containerSourceId
        )
        coordinator.tabsContainer = tabsContainer

        momentsTabsViewModel = BlazeSwiftUIMomentsWidgetViewModel(
            tabsWidgetConfiguration: BlazeSwiftUIMomentsTabsWidgetConfiguration(
                layout: .Presets.MomentsWidget.Row.verticalAnimatedThumbnailsRectangles,
                tabsContainer: tabsContainer
            )
        )

        SampleFollowEntitiesManager.shared.onFollowChanged = { [weak self] in
            guard let self else { return }
            self.coordinator?.handleFollowChanged(isViewVisible: self.isViewVisible)
        }
    }
}
