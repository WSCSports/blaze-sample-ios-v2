//
//  EntryPointView.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 27/06/2025.
//

import UIKit


final class EntryPointView: UIView, UITextFieldDelegate {

    var onOpenLink: (() -> Void)?
    var onPlayStories: ((String) -> Void)?
    var onPlayMoments: ((String) -> Void)?
    var onPlayVideos: ((String) -> Void)?
    var onSingleStoryAction: (() -> Void)?
    var onSingleMomentAction: (() -> Void)?
    var onSingleVideoAction: (() -> Void)?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let storiesField = UITextField()
    private let momentsField = UITextField()
    private let videosField = UITextField()
    
    private lazy var linkButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "link_icn")
        config.title = EntryPointDefaultValues.UNIVERSAL_LINK_SPANNABLE_TEXT
        config.baseForegroundColor = .systemBlue
        config.imagePadding = 8
        config.imagePlacement = .leading

        let button = UIButton(configuration: config, primaryAction: nil)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.onOpenLink?()
        }), for: .touchUpInside)

        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTapToDismissKeyboard()
        setupLayout()
        populateContent()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTapToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        endEditing(true)
    }
    
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 28
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    private func populateContent() {
        storiesField.delegate = self
        momentsField.delegate = self
        videosField.delegate = self

        contentStack.addArrangedSubview(verticalGroupView([
            makeSectionLabel("Universal link"),
            linkButton
        ], spacing: 12))

        contentStack.addArrangedSubview(makeDivider())

        contentStack.addArrangedSubview(verticalGroupView([
            makeSectionLabel("Stories"),
            makeTextFieldWithPlayButton(
                textField: storiesField,
                text: ConfigManager.storiesRowLabel,
                onTap: { [weak self] in self?.onPlayStories?(self?.storiesField.text ?? "") }
            )
        ]))

        contentStack.addArrangedSubview(verticalGroupView([
            makeSectionLabel("Moments"),
            makeTextFieldWithPlayButton(
                textField: momentsField,
                text: ConfigManager.momentsRowLabel,
                onTap: { [weak self] in self?.onPlayMoments?(self?.momentsField.text ?? "") }
            )
        ]))

        contentStack.addArrangedSubview(verticalGroupView([
            makeSectionLabel("Videos"),
            makeTextFieldWithPlayButton(
                textField: videosField,
                text: ConfigManager.videosRowLabel,
                onTap: { [weak self] in self?.onPlayVideos?(self?.videosField.text ?? "") }
            )
        ]))
        
        contentStack.addArrangedSubview(makeDivider())

        contentStack.addArrangedSubview(verticalGroupView([
            makeSectionLabel("Single ID"),
            makeHorizontalButtonGroup(
                [
                    ("Play story", { [weak self] in
                        self?.onSingleStoryAction?()
                    }),
                    ("Play moment", { [weak self] in
                        self?.onSingleMomentAction?()
                    }),
                    ("Play video", { [weak self] in
                        self?.onSingleVideoAction?()
                    })]
            )
        ]))

    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 14)
        label.heightAnchor.constraint(equalToConstant: 22).isActive = true
        return label
    }

    private func makeTextFieldWithPlayButton(textField: UITextField, text: String, onTap: @escaping () -> Void) -> UIStackView {
        textField.text = text
        textField.borderStyle = .none
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.cornerRadius = 8
        textField.setLeftPadding(12)
        textField.heightAnchor.constraint(equalToConstant: 42).isActive = true

        let button = UIButton(type: .system)
        button.setTitle("Play", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.heightAnchor.constraint(equalToConstant: 42).isActive = true
        button.widthAnchor.constraint(equalToConstant: 90).isActive = true
        button.addAction(UIAction(handler: { _ in onTap() }), for: .touchUpInside)

        let hStack = UIStackView(arrangedSubviews: [textField, button])
        hStack.axis = .horizontal
        hStack.spacing = 8
        hStack.distribution = .fillProportionally

        return hStack
    }

    private func makeHorizontalButtonGroup(_ configs: [(String, (() -> Void)?)]) -> UIStackView {
        let buttons = configs.map { config -> UIButton in
            let button = UIButton(type: .system)
            button.setTitle(config.0, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .black
            button.layer.cornerRadius = 12
            button.titleLabel?.font = .boldSystemFont(ofSize: 14)
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            
            button.addAction(UIAction(handler: { _ in
                config.1?()
            }), for: .touchUpInside)
            return button
        }

        let hStack = UIStackView(arrangedSubviews: buttons)
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.distribution = .fillEqually
        return hStack
    }

    private func makeDivider() -> UIView {
        let line = UIView()
        line.backgroundColor = .lightGray.withAlphaComponent(0.5)
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }
}

extension EntryPointView {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

private func verticalGroupView(_ views: [UIView], spacing: CGFloat = 8) -> UIStackView {
    let stack = UIStackView(arrangedSubviews: views)
    stack.axis = .vertical
    stack.spacing = spacing
    return stack
}

private extension UITextField {
    func setLeftPadding(_ padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: 0))
        leftView = paddingView
        leftViewMode = .always
    }
}
