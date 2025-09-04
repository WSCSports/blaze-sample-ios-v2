//
//  BaseContentContainerViewController.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 17/06/2025.

import UIKit

class BaseContentContainerViewController: UIViewController {

    private var contentTopConstraint: NSLayoutConstraint?
    private var contentBottomConstraint: NSLayoutConstraint?
    private var widgetContentHeightConstraint: NSLayoutConstraint?

    // MARK: - Internal

    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    // MARK: - Private

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutContentView()
    }

    func layoutContentView() {
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Default top constraint (can be updated later)
        contentTopConstraint = contentView.topAnchor.constraint(equalTo: view.topAnchor)
        contentTopConstraint?.isActive = true
    }

    func updateContentTopAnchor(relativeTo anchor: NSLayoutYAxisAnchor) {
        contentTopConstraint?.isActive = false

        let newConstraint = contentView.topAnchor.constraint(equalTo: anchor, constant: 16)
        newConstraint.isActive = true
        contentTopConstraint = newConstraint
    }

    func setContentViewFixedHeight(_ height: CGFloat) {
        // Remove bottom constraint if active
        contentBottomConstraint?.isActive = false

        if widgetContentHeightConstraint == nil {
            let constraint = contentView.heightAnchor.constraint(equalToConstant: height)
            constraint.priority = .required
            constraint.isActive = true
            widgetContentHeightConstraint = constraint
        } else {
            widgetContentHeightConstraint?.constant = height
            widgetContentHeightConstraint?.isActive = true
        }

        view.layoutIfNeeded()
    }
    
    func setContentViewBottomAnchor(to anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0) {
        widgetContentHeightConstraint?.isActive = false

        contentBottomConstraint?.isActive = false
        let constraint = contentView.bottomAnchor.constraint(equalTo: anchor, constant: constant)
        constraint.isActive = true
        contentBottomConstraint = constraint

        view.layoutIfNeeded()
    }
}
