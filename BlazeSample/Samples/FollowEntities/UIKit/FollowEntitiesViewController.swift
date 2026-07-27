//
//  FollowEntitiesViewController.swift
//  blaze-sample-ios-v2
//

import UIKit
import BlazeSDK

/// Demonstrates the BlazeSDK Follow Entities feature via a tabs-backed Moments widget
/// (Trending / For You / Your Picks). "Your Picks" is personalized from followed entities.
/// The follow-change choreography lives in `FollowTabsRefreshCoordinator`; this controller only
/// wires the widget to it.
class FollowEntitiesViewController: UIViewController {

    private static let containerSourceId = "follow-entities-moments-tabs-id"

    private let contentView = MixedWidgetsView()
    private let viewModel = WidgetsViewModel(widgetType: .mixed)

    private var momentsRowWidgetView: BlazeMomentsWidgetRowView?
    private var coordinator: FollowTabsRefreshCoordinator?
    private var isViewVisible = false

    override func loadView() {
        self.view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initWidget()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewVisible = true
        coordinator?.viewDidAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isViewVisible = false
    }

    private func initWidget() {
        let coordinator = FollowTabsRefreshCoordinator(containerSourceId: Self.containerSourceId) { [weak self] in
            self?.momentsRowWidgetView?.reloadData(progressType: .skeleton)
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

        let widget = BlazeMomentsWidgetRowView(layout: viewModel.momentsRowBaseLayout, tabsContainer: tabsContainer)
        widget.widgetIdentifier = "follow-entities-moments-tabs-row-id"
        widget.widgetDelegate = viewModel.widgetDelegate
        self.momentsRowWidgetView = widget

        let section = WidgetSectionView(height: 300, title: "Moments Follow Tabs")
        widget.embedInView(section.containerView)
        widget.reloadData(progressType: .skeleton)
        contentView.stackView.addArrangedSubview(section)

        SampleFollowEntitiesManager.shared.onFollowChanged = { [weak self] in
            guard let self else { return }
            self.coordinator?.handleFollowChanged(isViewVisible: self.isViewVisible)
        }
    }
}
