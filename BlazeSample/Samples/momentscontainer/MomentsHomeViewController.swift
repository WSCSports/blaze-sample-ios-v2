//
//  MomentsHomeViewController.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 24/06/2025.
//

import UIKit
import Combine

final class MomentsHomeViewController: UIViewController {

    private let viewModel: MomentsContainerViewModel

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
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        
        let title = UILabel()
        title.text = "Open moments tab on click"
        title.numberOfLines = 0
        title.textAlignment = .left
        title.font = UIFont.boldSystemFont(ofSize: 18)
        title.translatesAutoresizingMaskIntoConstraints = false

        let subtitle = UILabel()
        subtitle.text = "Demo showing how a button click triggers the moments container without leaving the current view."
        subtitle.numberOfLines = 0
        subtitle.textAlignment = .left
        subtitle.font = UIFont.systemFont(ofSize: 14)
        subtitle.translatesAutoresizingMaskIntoConstraints = false

        let button = UIButton(type: .system)
        button.setTitle("Open Moments tab", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openMomentsTab), for: .touchUpInside)

        view.addSubview(title)
        view.addSubview(subtitle)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            title.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 12),
            subtitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            subtitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            button.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 24),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 42)
        ])
    }

    @objc private func openMomentsTab() {
        viewModel.triggerMomentsTabSelected()
    }
}
