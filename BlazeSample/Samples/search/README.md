# Search Module

This module demonstrates how to build a custom search screen using BlazeSDK, matching the layout and behavior of the SDK's built-in search screen. It shows how to drive three widget types — Stories, Moments, and Videos — from a single `BlazeDataSourceType.search(searchText:)` data source, coordinate their load callbacks to compute a unified UI state, and display a suggestions grid when the search field is empty.

## Main Components

### SearchViewController

- The main entry point for the search module.
- Accepts an optional `suggestionsDataSource: BlazeDataSourceType?` to enable a suggestions grid.
- Manages four BlazeSDK widgets: `BlazeStoriesWidgetRowView`, `BlazeMomentsWidgetRowView`, `BlazeVideosWidgetRowView`, and optionally `BlazeMomentsWidgetGridView` (suggestions).
- Connects `SearchHeaderView` text/back actions to `SearchViewModel` and propagates `UIState` changes to `SearchView`.
- Uses a single shared `BlazeWidgetDelegate` for all widgets, enabling the ViewModel to track when all search widgets have finished loading.
- Hides the navigation bar on appear and restores it on disappear — works correctly both when pushed and when presented modally.

### SearchHeaderView

- Custom header view replacing `UISearchBar`, matching the SDK's built-in design.
- Consists of a back button, a rounded search container (search icon + `UITextField` + animated clear button), and a bottom separator.
- Exposes a `textPublisher: AnyPublisher<String, Never>` for Combine-based text observation.
- The owning view controller connects `backButton` actions directly.

### SearchViewModel

- Holds the search state machine (`UIState`) and drives the active data source (`BlazeDataSourceType?`) via `@Published` properties.
- Tracks per-widget load results in a `[WidgetType: WidgetState]` dictionary.
- Computes the final `UIState` only after all three search widgets have reported completion via `BlazeWidgetDelegate.onDataLoadComplete`.
- Handles suggestions widget callbacks separately — updates `UIState.empty(hasSuggestions:)` to show/hide the suggestions grid.
- Accepts optional `suggestionsDataSource` in `init` to configure suggestions support.

### SearchView

- A `UIView` subclass that owns the full view hierarchy: custom header, suggestions view, scroll view with content sections, and no-results label.
- Exposes: `headerView`, `suggestionsView`, `embed(storiesWidget:)`, `embed(momentsWidget:)`, `embed(videosWidget:)`, `embed(suggestionsWidget:)`, and `transition(to:)`.
- Handles all animations: fade in/out of suggestions, section visibility transitions, no-results label.

## Search Flow

```
User types in SearchHeaderView.searchTextField
    → textPublisher emits text change
    → viewModel.updateSearchText(_:)
        → if empty: uiState = .empty(hasSuggestions: ...)
        → if not empty: waits for Search button tap

User taps Return on keyboard
    → UITextFieldDelegate.textFieldShouldReturn
    → viewModel.performSearch()
        → uiState = .loading
        → activeSearchDataSource = BlazeDataSourceType.search(searchText:)
            → all three search widgets call updateDataSourceType(...)
            → each widget calls BlazeWidgetDelegate.onDataLoadComplete
                → viewModel tracks per-widget result
                → when all three loaded: uiState = .content / .noResults / .error
                    → searchView.transition(to:) updates the UI
```

## UIState Machine

| State | Trigger | UI |
|---|---|---|
| `.empty(hasSuggestions: false)` | Initial load with no suggestions data source | All sections hidden |
| `.empty(hasSuggestions: true)` | Initial load or search cleared, suggestions loaded content | Suggestions grid visible |
| `.loading` | `performSearch()` called | All sections shown (widgets load silently) |
| `.content(hasStories:hasMoments:hasVideos:)` | At least one widget returned results | Sections with results shown, empty sections hidden |
| `.noResults(searchText:)` | All widgets returned 0 items | "No results" label shown, sections hidden |
| `.error(message:)` | All widgets failed | Error message shown, sections hidden |

## Widget Configuration

| Widget | Layout preset | Widget identifier | Height |
|---|---|---|---|
| `BlazeStoriesWidgetRowView` | `StoriesWidget.Row.circles` | `search_stories` | 150 pt |
| `BlazeMomentsWidgetRowView` | `MomentsWidget.Row.verticalAnimatedThumbnailsRectangles` | `search_moments` | 290 pt |
| `BlazeVideosWidgetRowView` | `VideosWidget.Row.horizontalRectangles` | `search_videos` | 211 pt |
| `BlazeMomentsWidgetGridView` | `MomentsWidget.Grid.threeColumnsVerticalRectangles` (customized) | `search_suggestions` | fills available space |

Widget identifiers are used by `SearchViewModel` to map `onDataLoadComplete` callbacks back to the correct widget type.

## Suggestions Grid

When `SearchViewController` is initialised with a `suggestionsDataSource`, a `BlazeMomentsWidgetGridView` is shown while the search field is empty:

```swift
// Open search with suggestions from the current moments feed
let searchVC = SearchViewController(
    suggestionsDataSource: .labels(.singleLabel("your-label"))
)
```

The suggestions widget uses a 3-column vertical grid with tight spacing (3pt) and no item titles, matching the SDK's built-in layout. When the user starts typing, the grid animates out and is replaced by the search results sections.

## Navigation

The screen supports two presentation modes; the back button adapts automatically:

- **Pushed** (default, from the HomeView list): the navigation bar is hidden on appear and restored on disappear. The custom header's back button calls `navigationController?.popViewController`.
- **Presented modally** (e.g. from a moments player): set `modalPresentationStyle = .fullScreen` before presenting. The back button calls `dismiss(animated: true)`.

```swift
// Modal presentation example
let searchVC = SearchViewController(suggestionsDataSource: dataSource)
searchVC.modalPresentationStyle = .fullScreen
present(searchVC, animated: true)
```

## Usage

1. Navigate to the Search module from the main application navigation.
2. Type a search query in the search field — the field activates automatically on screen open.
3. Tap the **Search** key on the keyboard to trigger the search request.
4. Results for Stories, Moments, and Videos appear as separate sections once all three widgets finish loading.
5. Sections with no results are hidden automatically; a "No results" message appears if all widgets return empty.
6. Clearing the search field resets the screen to the initial empty/suggestions state.
7. Tap the back button or anywhere outside the keyboard to dismiss/navigate back.
