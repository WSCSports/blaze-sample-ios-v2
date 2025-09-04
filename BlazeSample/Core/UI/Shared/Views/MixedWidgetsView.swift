//
//  MixedWidgetsView.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 23/06/2025.
//

import UIKit

class MixedWidgetsView: UIView {

    // MARK: - Subviews

    let contentView: ScrollStackContentView = {
        let view = ScrollStackContentView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Accessors

    var scrollView: UIScrollView { contentView.scrollView }
    var refreshControl: UIRefreshControl { contentView.refreshControl }
    var stackView: UIStackView { contentView.stackView }

    // MARK: - Private

    var gradientBottomConstraint: NSLayoutConstraint?
    var gradientFallbackHeightConstraint: NSLayoutConstraint?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func setupLayout() {

        backgroundColor = .systemBackground

        addSubview(contentView)

        scrollView.contentInsetAdjustmentBehavior = .automatic

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
