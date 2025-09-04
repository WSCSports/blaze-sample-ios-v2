//
//  MomentsViewController.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 24/06/2025.
//


import UIKit
import BlazeSDK

///
/// This ViewController demonstrates how to use BlazeMomentsPlayerContainer.
/// It contains a BlazeMomentsPlayerContainer instance that starts playing moments instantly.
/// For more information, see https://dev.wsc-sports.com/docs/ios-moments-player#/.
///

final class MomentsViewController: UIViewController {

    let viewModel: MomentsContainerViewModel
    
    private lazy var momentsPlayerContainer: BlazeMomentsPlayerContainer = {
        let dataSource = BlazeDataSourceType.labels(.singleLabel(MomentsContainerValues.momentsLabel))
        return .init(
            dataSourceType: dataSource,
            shouldOrderMomentsByReadStatus: true,
            containerDelegate: viewModel.createContainerDelegate(),
            containerIdentifier: MomentsContainerValues.instantMomentsContainerId,
            style: viewModel.momentsPlayerStyle
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startMomentsInContainer()
    }
    
    init(viewModel: MomentsContainerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func startMomentsInContainer() {
        momentsPlayerContainer.startPlaying(in: self)
    }
}

