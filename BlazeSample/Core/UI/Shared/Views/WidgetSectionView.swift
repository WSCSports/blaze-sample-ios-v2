//
//  WidgetSectionView.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 23/06/2025.
//

import UIKit

final class WidgetSectionView: UIStackView {

    private var height: CGFloat?
    private var heightConstraint: NSLayoutConstraint?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    let titleContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 0)
    }

    init(height: CGFloat = 0, title: String) {
        self.height = height
        super.init(frame: .zero)

        self.axis = .vertical
        self.spacing = 0
        self.translatesAutoresizingMaskIntoConstraints = false

        setupTitle(title)
        setupContainer()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupTitle(_ title: String) {
        titleLabel.text = title
        titleContainer.addArrangedSubview(titleLabel)

        let containerWrapper = UIView()
        containerWrapper.translatesAutoresizingMaskIntoConstraints = false
        containerWrapper.addSubview(titleContainer)

        NSLayoutConstraint.activate([
            titleContainer.topAnchor.constraint(equalTo: containerWrapper.topAnchor, constant: 16),
            titleContainer.leadingAnchor.constraint(equalTo: containerWrapper.leadingAnchor, constant: 16),
            titleContainer.trailingAnchor.constraint(equalTo: containerWrapper.trailingAnchor, constant: -16),
            titleContainer.bottomAnchor.constraint(equalTo: containerWrapper.bottomAnchor, constant: -16)
        ])

        addArrangedSubview(containerWrapper)
    }

    private func setupContainer() {
        addArrangedSubview(containerView)
        
        if let height = height, height > 0 {
            heightConstraint = containerView.heightAnchor.constraint(equalToConstant: height)
            heightConstraint?.isActive = true
        } else {
            containerView.setContentHuggingPriority(.required, for: .vertical)
            containerView.setContentCompressionResistancePriority(.required, for: .vertical)
        }
    }
}
