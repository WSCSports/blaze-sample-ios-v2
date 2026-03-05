import UIKit
import BlazeSDK

///
/// `SearchView` owns the full view hierarchy for the search screen.
///
/// Public interface:
/// - `headerView` — connect back button and text field actions from the view controller.
/// - `suggestionsView` — container for the suggestions grid widget (shown when search field is empty).
/// - `embed(storiesWidget:)`, `embed(momentsWidget:)`, `embed(videosWidget:)` — embed SDK widgets
///   into the appropriate section containers.
/// - `embed(suggestionsWidget:)` — embed the suggestions grid into `suggestionsView`.
/// - `transition(to:)` — apply a `SearchViewModel.UIState` to show or hide sections and labels.
///
final class SearchView: UIView {

    // MARK: - Layout Constants

    private enum Layout {
        static let headerHeight: CGFloat   = 64
        static let storiesHeight: CGFloat  = 150
        static let momentsHeight: CGFloat  = 290
        static let videosHeight: CGFloat   = 211
        static let sectionSpacing: CGFloat = 24
        static let contentInset: CGFloat   = 0
    }

    // MARK: - Public Subviews

    let headerView = SearchHeaderView()

    /// Container for the suggestions grid widget. Occupies the full area below the header.
    /// Hidden by default; shown when `UIState.empty(hasSuggestions: true)` is received.
    let suggestionsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    // MARK: - Private Subviews

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = true
        return sv
    }()

    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = Layout.sectionSpacing
        return sv
    }()

    private let storiesSection  = SearchSectionView(title: "Stories")
    private let momentsSection  = SearchSectionView(title: "Quick Highlights")
    private let videosSection   = SearchSectionView(title: "Full Videos")

    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // MARK: - Animation State

    private var suggestionsIntendedVisible = false

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupInitialState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Widget Embedding

    func embed(storiesWidget widget: UIView) {
        embedWidget(widget, in: storiesSection.containerView, height: Layout.storiesHeight)
    }

    func embed(momentsWidget widget: UIView) {
        embedWidget(widget, in: momentsSection.containerView, height: Layout.momentsHeight)
    }

    func embed(videosWidget widget: UIView) {
        embedWidget(widget, in: videosSection.containerView, height: Layout.videosHeight)
    }

    /// Embeds the suggestions grid widget into `suggestionsView`, pinned to all edges.
    func embed(suggestionsWidget widget: UIView) {
        widget.translatesAutoresizingMaskIntoConstraints = false
        suggestionsView.addSubview(widget)
        NSLayoutConstraint.activate([
            widget.topAnchor.constraint(equalTo: suggestionsView.topAnchor),
            widget.leadingAnchor.constraint(equalTo: suggestionsView.leadingAnchor),
            widget.trailingAnchor.constraint(equalTo: suggestionsView.trailingAnchor),
            widget.bottomAnchor.constraint(equalTo: suggestionsView.bottomAnchor)
        ])
    }

    // MARK: - State Transitions

    /// Applies the given `UIState` to the view: shows/hides suggestions, content sections,
    /// and the no-results label, with animated transitions.
    func transition(to state: SearchViewModel.UIState) {
        switch state {
        case .empty(let hasSuggestions):
            hideAllSections(animated: false)
            noResultsLabel.isHidden = true
            if hasSuggestions {
                showSuggestionsView()
            } else {
                hideSuggestionsView()
            }

        case .loading:
            hideSuggestionsView()
            noResultsLabel.isHidden = true
            showAllSections()

        case .content(let hasStories, let hasMoments, let hasVideos):
            hideSuggestionsView()
            noResultsLabel.isHidden = true
            updateSectionsVisibility(hasStories: hasStories, hasMoments: hasMoments, hasVideos: hasVideos)

        case .noResults(let searchText):
            hideSuggestionsView()
            hideAllSections(animated: true)
            noResultsLabel.text = "No results found for '\(searchText)'"
            noResultsLabel.isHidden = false

        case .error(let message):
            hideSuggestionsView()
            hideAllSections(animated: true)
            noResultsLabel.text = message
            noResultsLabel.isHidden = false
        }
    }

    // MARK: - Private Setup

    private func setupLayout() {
        backgroundColor = .systemBackground

        addSubview(headerView)
        addSubview(scrollView)
        addSubview(suggestionsView)
        addSubview(noResultsLabel)

        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(storiesSection)
        contentStack.addArrangedSubview(momentsSection)
        contentStack.addArrangedSubview(videosSection)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: Layout.headerHeight),

            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),

            suggestionsView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            suggestionsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            suggestionsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            suggestionsView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: Layout.contentInset),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: widthAnchor),

            noResultsLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 26),
            noResultsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            noResultsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    private func setupInitialState() {
        [storiesSection, momentsSection, videosSection].forEach {
            $0.alpha = 0
            $0.isHidden = true
        }
        suggestionsView.isHidden = true
        suggestionsView.alpha = 0
    }

    private func embedWidget(_ widget: UIView, in container: UIView, height: CGFloat) {
        container.addSubview(widget)
        widget.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widget.topAnchor.constraint(equalTo: container.topAnchor),
            widget.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            widget.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            widget.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            widget.heightAnchor.constraint(equalToConstant: height)
        ])
    }

    // MARK: - Suggestions Animations

    private func showSuggestionsView() {
        suggestionsIntendedVisible = true
        suggestionsView.isHidden = false
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.suggestionsView.alpha = 1
        }
    }

    private func hideSuggestionsView() {
        suggestionsIntendedVisible = false
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.suggestionsView.alpha = 0
        } completion: { [weak self] _ in
            guard let self, !self.suggestionsIntendedVisible else { return }
            self.suggestionsView.isHidden = true
        }
    }

    // MARK: - Section Animations

    private func showAllSections() {
        [storiesSection, momentsSection, videosSection].forEach { $0.isHidden = false }
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.storiesSection.alpha = 1
            self.momentsSection.alpha = 1
            self.videosSection.alpha  = 1
        }
    }

    private func hideAllSections(animated: Bool) {
        let sections = [storiesSection, momentsSection, videosSection]
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                sections.forEach { $0.alpha = 0 }
            } completion: { _ in
                sections.forEach { $0.isHidden = true }
            }
        } else {
            sections.forEach {
                $0.alpha = 0
                $0.isHidden = true
            }
        }
    }

    private func updateSectionsVisibility(hasStories: Bool, hasMoments: Bool, hasVideos: Bool) {
        let pairs: [(SearchSectionView, Bool)] = [
            (storiesSection, hasStories),
            (momentsSection, hasMoments),
            (videosSection,  hasVideos)
        ]

        pairs.forEach { section, visible in
            if visible { section.isHidden = false }
        }

        UIView.animate(
            withDuration: 0.45,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0,
            options: [.curveEaseInOut, .allowUserInteraction]
        ) {
            pairs.forEach { section, visible in section.alpha = visible ? 1 : 0 }
            self.contentStack.layoutIfNeeded()
        } completion: { _ in
            pairs.forEach { section, visible in if !visible { section.isHidden = true } }
        }
    }
}

// MARK: - SearchSectionView

private final class SearchSectionView: UIView {

    let containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()

    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(titleLabel)
        addSubview(containerView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
