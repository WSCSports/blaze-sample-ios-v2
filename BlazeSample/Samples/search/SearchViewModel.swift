import Foundation
import Combine
import BlazeSDK

///
/// `SearchViewModel` manages the state machine for the search screen.
///
/// A single `BlazeWidgetDelegate` is shared across all widgets (Stories, Moments, Videos,
/// and optionally Suggestions). Each widget's load result is stored in a
/// `[WidgetType: WidgetState]` dictionary, and `UIState` is only recomputed once all three
/// search widgets have reported completion via `onDataLoadComplete`.
///
/// The optional `suggestionsDataSource` populates a grid widget shown when the search
/// field is empty. When provided, `UIState.empty(hasSuggestions: true)` is emitted and
/// the suggestions grid is visible.
///
final class SearchViewModel {

    // MARK: - Types

    enum WidgetType {
        case stories
        case moments
        case videos
    }

    private struct WidgetState {
        var itemCount: Int = 0
        var isLoaded: Bool = false
        var result: BlazeResult = .success(())
        var hasContent: Bool { itemCount > 0 }
    }

    /// Represents the possible visual states of the search screen.
    enum UIState {
        /// Initial state or after the search bar is cleared.
        /// `hasSuggestions` controls whether the suggestions grid is visible.
        case empty(hasSuggestions: Bool)
        /// Search was triggered; waiting for all three widgets to finish loading.
        case loading
        /// All widgets finished loading; at least one returned results.
        case content(hasStories: Bool, hasMoments: Bool, hasVideos: Bool)
        /// All widgets finished loading but all returned 0 items.
        case noResults(searchText: String)
        /// All widgets failed with an error.
        case error(message: String)
    }

    // MARK: - Widget Identifiers

    enum WidgetId {
        static let stories     = "search_stories"
        static let moments     = "search_moments"
        static let videos      = "search_videos"
        /// Identifier for the suggestions grid (shown when the search field is empty).
        static let suggestions = "search_suggestions"
    }

    // MARK: - Properties

    /// The data source used to populate the suggestions grid.
    /// When `nil`, no suggestions widget is created and `.empty(hasSuggestions: false)` is used.
    let suggestionsDataSource: BlazeDataSourceType?

    private(set) var currentSearchText: String = ""

    private var widgetStates: [WidgetType: WidgetState] = [
        .stories: WidgetState(),
        .moments: WidgetState(),
        .videos:  WidgetState()
    ]

    @Published var uiState: UIState = .empty(hasSuggestions: false)
    @Published private(set) var activeSearchDataSource: BlazeDataSourceType?

    // MARK: - Init

    init(suggestionsDataSource: BlazeDataSourceType? = nil) {
        self.suggestionsDataSource = suggestionsDataSource
    }

    // MARK: - Public Methods

    /// Returns a single `BlazeWidgetDelegate` to be assigned to all widgets.
    /// Using one shared delegate lets the ViewModel receive callbacks from every widget
    /// and wait until all search widgets have completed before computing the final `UIState`.
    func makeWidgetDelegate() -> BlazeWidgetDelegate {
        BlazeWidgetDelegate(
            onDataLoadComplete: { [weak self] params in
                self?.handleDataLoadComplete(
                    sourceId: params.sourceId,
                    itemsCount: params.itemsCount,
                    result: params.result
                )
            }
        )
    }

    /// Sets the initial UI state based on whether a suggestions data source is available.
    /// Call this after all widgets have been created and embedded.
    func initialize() {
        uiState = .empty(hasSuggestions: suggestionsDataSource != nil)
    }

    func updateSearchText(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        currentSearchText = trimmed
        if trimmed.isEmpty {
            clearSearch()
        }
    }

    /// Triggers a search for the current text.
    /// Sets `activeSearchDataSource` to `BlazeDataSourceType.search(searchText:)`, which
    /// causes all subscribed search widgets to reload their content from the search endpoint.
    func performSearch() {
        guard !currentSearchText.isEmpty else { return }
        uiState = .loading
        resetWidgetStates()
        activeSearchDataSource = BlazeDataSourceType.search(searchText: currentSearchText)
    }

    // MARK: - Private Methods

    private func clearSearch() {
        currentSearchText = ""
        resetWidgetStates()
        uiState = .empty(hasSuggestions: suggestionsDataSource != nil)
    }

    private func resetWidgetStates() {
        widgetStates.keys.forEach { widgetStates[$0] = WidgetState() }
    }

    private func hasContent(for type: WidgetType) -> Bool {
        widgetStates[type]?.hasContent ?? false
    }

    private func allWidgetsLoaded() -> Bool {
        widgetStates.values.allSatisfy { $0.isLoaded }
    }

    private func anyWidgetHasContent() -> Bool {
        widgetStates.values.contains { $0.hasContent }
    }

    private func allWidgetsFailed() -> Error? {
        let errors = widgetStates.values.compactMap { state -> Error? in
            if case .failure(let error) = state.result { return error }
            return nil
        }
        return errors.count == widgetStates.count ? errors.first : nil
    }

    private func handleDataLoadComplete(sourceId: String?, itemsCount: Int, result: BlazeResult) {
        guard let sourceId else { return }

        if sourceId == WidgetId.suggestions {
            handleSuggestionsLoadComplete(itemsCount: itemsCount)
            return
        }

        guard !currentSearchText.isEmpty else { return }

        switch result {
        case .success:
            updateWidgetState(for: sourceId, itemCount: itemsCount, result: result)
        case .failure:
            updateWidgetState(for: sourceId, itemCount: 0, result: result)
        }

        guard allWidgetsLoaded() else { return }

        if let error = allWidgetsFailed(), !anyWidgetHasContent() {
            uiState = .error(message: error.localizedDescription)
        } else {
            uiState = computeContentState()
        }
    }

    /// Updates the empty state to reflect whether the suggestions widget has content.
    /// Only transitions if we're still in the `.empty` state (i.e. no active search).
    private func handleSuggestionsLoadComplete(itemsCount: Int) {
        guard case .empty(_) = uiState else { return }
        uiState = .empty(hasSuggestions: itemsCount > 0)
    }

    private func computeContentState() -> UIState {
        guard !currentSearchText.isEmpty else {
            return .empty(hasSuggestions: suggestionsDataSource != nil)
        }

        let hasStories = hasContent(for: .stories)
        let hasMoments = hasContent(for: .moments)
        let hasVideos  = hasContent(for: .videos)

        if hasStories || hasMoments || hasVideos {
            return .content(hasStories: hasStories, hasMoments: hasMoments, hasVideos: hasVideos)
        }
        return .noResults(searchText: currentSearchText)
    }

    private func updateWidgetState(for sourceId: String, itemCount: Int, result: BlazeResult) {
        guard let type = widgetType(for: sourceId) else { return }
        widgetStates[type] = WidgetState(itemCount: itemCount, isLoaded: true, result: result)
    }

    private func widgetType(for sourceId: String) -> WidgetType? {
        switch sourceId {
        case WidgetId.stories: return .stories
        case WidgetId.moments: return .moments
        case WidgetId.videos:  return .videos
        default: return nil
        }
    }
}
