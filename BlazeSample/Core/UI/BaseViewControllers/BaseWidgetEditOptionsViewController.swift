//
//  BaseEditOptionsViewController.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 13/06/2025.

import UIKit
import SwiftUI
import Combine
import BlazeSDK

class BaseWidgetEditOptionsViewController: BaseWidgetViewController {

    var viewModel: WidgetsViewModel = .init()
    var cancellables: Set<AnyCancellable> = []

    private let customizationLabel: UILabel = {
        let label = UILabel()
        label.text = "Customizations applied:"
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .black
        label.isHidden = true
        return label
    }()

    private var customizationTagsHostingController: UIHostingController<TagListView>?

    private let showButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View edit options", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    let shadowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        return view
    }()

    init(viewModel: WidgetsViewModel = WidgetsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        bindViewModel()

        setupCustomizationHeader()
        setupShadowView()
        layoutButton()
        showButton.addTarget(self, action: #selector(showBottomSheet), for: .touchUpInside)
        updateCustomizationHeader()
        initWidgetView()
    }
    
    private func bindViewModel() {
        viewModel.$widgetDataState
            .removeDuplicates()
            .sink { [weak self] newDataState in
                self?.onNewDatasourceState(newDataState)
            }
            .store(in: &cancellables)

        viewModel.$styleState
            .removeDuplicates()
            .sink { [weak self] newOptions in
                self?.onNewWidgetLayoutState(newOptions)
            }
            .store(in: &cancellables)
    }

    // Initializes the Moments Grid Widget view with layout and dataSource.
    func initWidgetView() {
        // override in subclass if needed
    }

    // Handles the data state update based on new customization state.
    func onNewDatasourceState(_ newDataState: WidgetDataState) {
        // override in subclass if needed
    }
    
    // Handles the layout update based on new customization state.
    func onNewWidgetLayoutState(_ newStyle: WidgetLayoutStyleState) {
        // override in subclass if needed
    }
    
    private func setupCustomizationHeader() {
        view.addSubview(customizationLabel)
        customizationLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            customizationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 11),
            customizationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            customizationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func layoutSwiftUITagsView(with tags: [String]) {
        customizationTagsHostingController?.view.removeFromSuperview()
        customizationTagsHostingController?.removeFromParent()

        guard !tags.isEmpty else {
            customizationTagsHostingController = nil
            updateContentTopAnchor(relativeTo: view.topAnchor)
            return
        }

        let swiftUIView = TagListView(tags: tags)
        let hosting = UIHostingController(rootView: swiftUIView)
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.didMove(toParent: self)

        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: customizationLabel.bottomAnchor, constant: 8),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            hosting.view.heightAnchor.constraint(lessThanOrEqualToConstant: 240)
        ])

        customizationTagsHostingController = hosting
        updateContentTopAnchor(relativeTo: hosting.view.bottomAnchor)
    }

    private func layoutButton() {
        view.addSubview(showButton)
        showButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            showButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            showButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            showButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            showButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupShadowView() {
        view.addSubview(shadowView)

        NSLayoutConstraint.activate([
            shadowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            shadowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            shadowView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            shadowView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func updateCustomizationHeader() {
        let tags: [String] = [
            viewModel.styleState.isCustomAppearance ? "Appearance" : nil,
            viewModel.styleState.isCustomStatusIndicator ? "Indicator" : nil,
            viewModel.styleState.isCustomTitle ? "Title" : nil,
            viewModel.styleState.isCustomBadge ? "Badge" : nil,
            viewModel.styleState.isCustomItemStyleOverrides ? "Item override" : nil
        ].compactMap { $0 }

        customizationLabel.isHidden = tags.isEmpty
        layoutSwiftUITagsView(with: tags)
    }

    @objc private func showBottomSheet() {
        let detentState = DetentState()

        let sheetView = BottomSheetContainerWrapper(
            detentState: detentState,
            initialLabel: viewModel.widgetDataState.labelName,
            initialOrderType: viewModel.widgetDataState.orderType,
            styleState: viewModel.styleState
        ) { [weak self] newLabel, newOrderType, newOptions in
            self?.viewModel.widgetDataState = .init(labelName: newLabel, orderType: newOrderType)
            self?.viewModel.styleState = newOptions
            self?.updateCustomizationHeader()
        }

        let hostingController = UIHostingController(rootView: sheetView)
        hostingController.modalPresentationStyle = .pageSheet

        if let sheet = hostingController.sheetPresentationController {
            sheet.detents = [
                .custom(identifier: .init(EditOptionSheetContent.mainMenu.rawValue)) { _ in 240 },
                .custom(identifier: .init(EditOptionSheetContent.editSource.rawValue)) { _ in 396 },
                .custom(identifier: .init(EditOptionSheetContent.customization.rawValue)) { _ in 396 }
            ]
            sheet.selectedDetentIdentifier = detentState.selected
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false

            detentState.$selected.sink { newDetent in
                sheet.selectedDetentIdentifier = newDetent
            }
            .store(in: &cancellables)
        }

        present(hostingController, animated: true)
    }
}
