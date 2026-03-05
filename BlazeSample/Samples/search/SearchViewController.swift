import UIKit
import Combine
import BlazeSDK

///
/// `SearchViewController` demonstrates how to build a custom search screen using BlazeSDK,
/// matching the layout and behavior of the SDK's built-in search screen.
///
/// It drives three row widgets — Stories, Moments, and Videos — from a single
/// `BlazeDataSourceType.search(searchText:)` data source and coordinates their
/// load callbacks through `SearchViewModel` to display the appropriate UI state.
///
/// When a `suggestionsDataSource` is provided, a `BlazeMomentsWidgetGridView` is shown
/// while the search field is empty, allowing users to browse content before searching.
///
/// Navigation:
/// - When pushed via `NavigationController`: the navigation bar is hidden and the custom
///   header's back button pops the view controller.
/// - When presented modally (e.g. from `onSearchClicked`): the back button dismisses the screen.
///
class SearchViewController: UIViewController {

    // MARK: - View Model

    private let viewModel: SearchViewModel
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Widgets

    private var storiesWidget: BlazeStoriesWidgetRowView?
    private var momentsWidget: BlazeMomentsWidgetRowView?
    private var videosWidget: BlazeVideosWidgetRowView?
    private var suggestionsWidget: BlazeMomentsWidgetGridView?

    // MARK: - View

    private var searchView: SearchView { view as! SearchView }

    // MARK: - Init

    /// - Parameter suggestionsDataSource: When provided, a `BlazeMomentsWidgetGridView` grid
    ///   is shown while the search field is empty. Pass the data source of the content you
    ///   want to suggest (e.g. the same label used by the moments player that opened search).
    init(suggestionsDataSource: BlazeDataSourceType? = nil) {
        self.viewModel = SearchViewModel(suggestionsDataSource: suggestionsDataSource)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = SearchView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        setupTapGesture()
        setupWidgets()
    }

    // MARK: - Setup

    private func setupActions() {
        searchView.headerView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        searchView.headerView.searchTextField.delegate = self

        searchView.headerView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in self?.viewModel.updateSearchText(text) }
            .store(in: &cancellables)

        viewModel.$uiState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.searchView.transition(to: state) }
            .store(in: &cancellables)

        viewModel.$activeSearchDataSource
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dataSource in
                // .silent suppresses the SDK's built-in loading indicator — the screen
                // manages its own loading state via UIState.loading.
                self?.storiesWidget?.updateDataSourceType(dataSourceType: dataSource, progressType: .silent)
                self?.momentsWidget?.updateDataSourceType(dataSourceType: dataSource, progressType: .silent)
                self?.videosWidget?.updateDataSourceType(dataSourceType: dataSource, progressType: .silent)
            }
            .store(in: &cancellables)
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        searchView.addGestureRecognizer(tapGesture)
    }

    // MARK: - Widgets Setup

    private func setupWidgets() {
        // A single shared delegate is passed to all widgets so the ViewModel can aggregate
        // their onDataLoadComplete callbacks and compute UIState only after every search
        // widget has finished loading.
        let delegate = viewModel.makeWidgetDelegate()

        let stories = BlazeStoriesWidgetRowView(layout: BlazeWidgetLayout.Presets.StoriesWidget.Row.circles)
        stories.widgetIdentifier = SearchViewModel.WidgetId.stories
        stories.widgetDelegate = delegate
        storiesWidget = stories
        searchView.embed(storiesWidget: stories)

        let moments = BlazeMomentsWidgetRowView(layout: BlazeWidgetLayout.Presets.MomentsWidget.Row.verticalAnimatedThumbnailsRectangles)
        moments.widgetIdentifier = SearchViewModel.WidgetId.moments
        moments.widgetDelegate = delegate
        hideSearchButton(on: moments)
        momentsWidget = moments
        searchView.embed(momentsWidget: moments)

        let videos = BlazeVideosWidgetRowView(layout: BlazeWidgetLayout.Presets.VideosWidget.Row.horizontalRectangles)
        videos.widgetIdentifier = SearchViewModel.WidgetId.videos
        videos.widgetDelegate = delegate
        videosWidget = videos
        searchView.embed(videosWidget: videos)

        if let suggestionsDataSource = viewModel.suggestionsDataSource {
            var layout = BlazeWidgetLayout.Presets.MomentsWidget.Grid.threeColumnsVerticalRectangles
            layout.horizontalItemsSpacing = 3
            layout.verticalItemsSpacing = 3
            layout.margins = NSDirectionalEdgeInsets(top: 1, leading: 0, bottom: 1, trailing: 0)
            layout.widgetItemStyle.image.cornerRadius = 0
            layout.widgetItemStyle.title.isVisible = false

            let suggestions = BlazeMomentsWidgetGridView(layout: layout)
            suggestions.widgetIdentifier = SearchViewModel.WidgetId.suggestions
            suggestions.widgetDelegate = delegate
            suggestions.updateDataSourceType(dataSourceType: suggestionsDataSource, progressType: .silent)
            hideSearchButton(on: suggestions)
            suggestionsWidget = suggestions
            searchView.embed(suggestionsWidget: suggestions)
        }

        // Set initial state after all widgets are ready.
        viewModel.initialize()
    }

    /// Hides the search button on Moments widgets embedded inside the search screen
    /// to prevent recursive search opening.
    private func hideSearchButton(on widget: BlazeMomentsWidgetView) {
        guard var style = widget.momentsPlayerStyle else { return }
        style.buttons.search.isVisible = false
        style.buttons.search.isVisibleForAds = false
        widget.momentsPlayerStyle = style
    }

    // MARK: - Actions

    @objc private func backButtonTapped() {
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @objc private func dismissKeyboard() {
        searchView.headerView.searchTextField.resignFirstResponder()
    }

    private func performSearch() {
        searchView.headerView.searchTextField.resignFirstResponder()
        viewModel.performSearch()
    }
}

// MARK: - UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            return true
        }
        viewModel.updateSearchText(text)
        performSearch()
        return true
    }
}
