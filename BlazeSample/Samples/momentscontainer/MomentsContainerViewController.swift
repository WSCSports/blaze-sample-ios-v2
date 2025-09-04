//
//  MomentsContainerViewController.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 24/06/2025.
//

import UIKit
import Combine
import BlazeSDK

///
/// This ViewController demonstrates how to use BlazeMomentsPlayerContainer.
/// It contains two BlazeMomentsPlayerContainer instances.
/// For more information, see https://dev.wsc-sports.com/docs/ios-moments-player#/.
///

final class MomentsContainerViewController: UITabBarController {

    private let viewModel = MomentsContainerViewModel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
        
        let homeVC = MomentsHomeViewController(viewModel: viewModel)
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home_tab"), tag: 0)

        let momentsVC = MomentsViewController(viewModel: viewModel)
        momentsVC.tabBarItem = UITabBarItem(title: "Moments", image: UIImage(named: "moments_tab"), tag: 1)

        viewControllers = [homeVC, momentsVC]

        bindViewModel()
        prepareMomentsContainer()
    }

    private func bindViewModel() {
        viewModel.onMomentsTabSelected
            .sink { [weak self] in
                self?.selectedIndex = 1
            }
            .store(in: &cancellables)
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white

        appearance.stackedLayoutAppearance.selected.iconColor = .black
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.black]

        appearance.stackedLayoutAppearance.normal.iconColor = .gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    // Optional - prepare the containers for faster loading. We have two containers in this view controller.
    private func prepareMomentsContainer() {
        let instantDataSource = BlazeDataSourceType.labels(.singleLabel(MomentsContainerValues.momentsLabel))
        
        let instantMomentsContainer = BlazeMomentsPlayerContainer(
            dataSourceType: instantDataSource,
            containerIdentifier: MomentsContainerValues.instantMomentsContainerId
        )
        instantMomentsContainer.prepareMoments()
        
        let lazyDataSource = BlazeDataSourceType.labels(.singleLabel(MomentsContainerValues.momentsLabel))

        let lazyMomentsContainer = BlazeMomentsPlayerContainer(
            dataSourceType: lazyDataSource,
            containerIdentifier: MomentsContainerValues.lazyMomentsContainerId
        )
        lazyMomentsContainer.prepareMoments()
    }
}
