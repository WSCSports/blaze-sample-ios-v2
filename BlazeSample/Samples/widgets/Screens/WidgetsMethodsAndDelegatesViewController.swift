//
//  WidgetsMethodsAndDelegatesViewController.swift
//  blaze-sample-ios-v2
//
//  Created by Tuval Barak on 01/01/2026.
//

import UIKit
import BlazeSDK

/// `WidgetsMethodsAndDelegatesViewController`Demonstrates the different variations widget methods and custom delegates handlers.
///
/// ## onWidgetItemClickHandler Delegate:
///
/// The `onWidgetItemClickHandler` allows the app to intercept widget item clicks and
/// decide whether the SDK should handle them (sdkShouldHandle) or the app will handle
/// them manually (handledByApp). When returning handledByApp, you can use `play(from:)`
/// to manually trigger playback.
///
/// **Note:** The same implementation pattern applies to Moments and Videos widgets:
/// - `BlazeMomentsWidgetRowView` / `BlazeMomentsWidgetGridView`
/// - `BlazeVideosWidgetRowView` / `BlazeVideosWidgetGridView`
///
/// All widget types support the same `play()`, `play(from:)` methods and
/// `onWidgetItemClickHandler` delegate.
///
class WidgetsMethodsAndDelegatesViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = WidgetsViewModel(widgetType: .methodsDelegates)
    private var storiesWidget: BlazeStoriesWidgetRowView?
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let widgetContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let methodsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Play Methods"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var playDefaultButton: UIButton = {
        createButton(title: "play()", action: #selector(playDefaultTapped))
    }()
    
    private lazy var playFromIndexButton: UIButton = {
        createButton(title: "play(from: .index)", action: #selector(playFromIndexTapped))
    }()
    
    private lazy var playFromContentIdButton: UIButton = {
        createButton(title: "play(from: .contentId)", action: #selector(playFromContentIdTapped))
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWidget()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        // Widget section
        contentStackView.addArrangedSubview(widgetContainerView)
        
        // Title wrapper with padding
        let titleWrapper = UIView()
        titleWrapper.translatesAutoresizingMaskIntoConstraints = false
        titleWrapper.addSubview(methodsTitleLabel)
        contentStackView.addArrangedSubview(titleWrapper)
        
        // Buttons wrapper with padding
        let buttonsWrapper = UIView()
        buttonsWrapper.translatesAutoresizingMaskIntoConstraints = false
        buttonsWrapper.addSubview(buttonsStackView)
        contentStackView.addArrangedSubview(buttonsWrapper)
        
        buttonsStackView.addArrangedSubview(playDefaultButton)
        buttonsStackView.addArrangedSubview(playFromIndexButton)
        buttonsStackView.addArrangedSubview(playFromContentIdButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            widgetContainerView.heightAnchor.constraint(equalToConstant: 160),
            
            methodsTitleLabel.topAnchor.constraint(equalTo: titleWrapper.topAnchor),
            methodsTitleLabel.leadingAnchor.constraint(equalTo: titleWrapper.leadingAnchor, constant: 16),
            methodsTitleLabel.trailingAnchor.constraint(equalTo: titleWrapper.trailingAnchor, constant: -16),
            methodsTitleLabel.bottomAnchor.constraint(equalTo: titleWrapper.bottomAnchor),
            
            buttonsStackView.topAnchor.constraint(equalTo: buttonsWrapper.topAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: buttonsWrapper.leadingAnchor, constant: 16),
            buttonsStackView.trailingAnchor.constraint(equalTo: buttonsWrapper.trailingAnchor, constant: -16),
            buttonsStackView.bottomAnchor.constraint(equalTo: buttonsWrapper.bottomAnchor),
            
            playDefaultButton.heightAnchor.constraint(equalToConstant: 50),
            playFromIndexButton.heightAnchor.constraint(equalToConstant: 50),
            playFromContentIdButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    /// Initialize the stories widget with a data source and click handler.
    ///
    /// The `onWidgetItemClickHandler` parameter allows you to intercept clicks on widget items.
    /// When provided, it receives `BlazeWidgetItemClickParams` containing:
    /// - widgetId: The ID of the widget
    /// - contentIndex: The zero-based index of the clicked item
    /// - contentId: The unique content ID of the clicked item
    ///
    /// Return `BlazeWidgetItemClickHandlerState.sdkShouldHandle` to let the SDK handle the click,
    /// or `BlazeWidgetItemClickHandlerState.handledByApp` to handle it yourself.
    private func setupWidget() {
        let widgetLayout = viewModel.getWidgetLayoutBasePreset()
        let dataSource = BlazeDataSourceType.labels(
            .singleLabel(ConfigManager.storiesRowLabel)
        )
        
        let widget = BlazeStoriesWidgetRowView(layout: widgetLayout)
        widget.dataSourceType = dataSource
        widget.widgetIdentifier = "methods-delegates-stories-widget"
        widget.widgetDelegate = viewModel.widgetDelegate
        widget.shouldOrderWidgetByReadStatus = true
        
        // Set up click handler - always intercepts and manually triggers playback
        widget.onWidgetItemClickHandler = { [weak widget] params in
            // Example of usage - check if the user is subscribed (we are doign mock delay)
            var subscribed = false
            
            // User is subscribed: return `sdkShouldHandle`
            if subscribed {
                return .sdkShouldHandle
            } else {
                // User is not subscribed: do your own subscription flow, on completion triger the `play` method.
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Mock background work
                    // Play from the clicked item's content ID
                    widget?.play(from: .contentId(params.contentId))
                }
                return .handledByApp
            }
            
        }
        
        widget.embedInView(widgetContainerView)
        widget.reloadData(progressType: .skeleton)
        self.storiesWidget = widget
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    // MARK: - Actions
    
    @objc private func playDefaultTapped() {
        storiesWidget?.play()
    }
    
    @objc private func playFromIndexTapped() {
        // The index can be customized based on your needs
        let index = 3
        storiesWidget?.play(from: .index(index))
    }
    
    @objc private func playFromContentIdTapped() {
        // The content ID can be customized based on your needs
        let contentId = "65631c2f182ca9d8338f6b99"
        storiesWidget?.play(from: .contentId(contentId))
    }
}

