//
//  MomentsContainerTabsViewController.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 23/09/2025.
//

import UIKit
import BlazeSDK

class MomentsContainerTabsViewController: UIViewController {
    
    let viewModel: MomentsContainerViewModel
    
    init(viewModel: MomentsContainerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.momentsTabsContainer.startPlaying(in: self)
    }
}
