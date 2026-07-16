# Follow Entities Module

This module demonstrates the BlazeSDK Follow Entities feature end to end, via a single
personalized, tabs-backed Moments widget (Trending / For You / Your Picks). It's provided as two
parallel, functionally identical screens — one built with UIKit, one with SwiftUI — reachable
directly from the app's Home screen ("Follow Entities (UIKit)" / "Follow Entities (SwiftUI)").

## Main Components

### FollowEntitiesViewController (UIKit)
- Builds a tabs-backed moments widget (`BlazeMomentsWidgetRowView(layout:tabsContainer:)`) with
  three tabs: `Trending`, `For You`, and `Your Picks`

### FollowEntitiesSwiftUIView / FollowEntitiesSwiftUIViewModel (SwiftUI)
- Same three-tab widget, built with `BlazeSwiftUIMomentsRowWidgetView` and
  `BlazeSwiftUIMomentsWidgetViewModel(tabsWidgetConfiguration:)`

### Personalized "Your Picks"
- `Your Picks` is the Follow Entities example: it blends the user's followed entity labels with the general highlights label, ranks the followed entities first via `labelsPriority` (most recently followed on top) and sorts within the same priority with `orderType: .recentlyUpdatedFirst`, so personalized content leads and general highlights fill in whenever it runs short
- The in-player follow button is enabled on the tabs container's player style with entity resolution `Player -> Team -> Property`. A single player style applies to the whole tabs container, so the button appears on every tab
- Follow state is owned by `SampleFollowEntitiesManager` (see `Follow/`), which wraps `Blaze.shared.followEntitiesManager`, persists to `UserDefaults` via `SampleFollowEntitiesStorage`, and rebuilds the `Your Picks` tab on every follow change
- Follow changes are applied twofold: while the screen is visible the widget rebuilds right away; while the fullscreen player is open, the new `Your Picks` data source is swapped in via `upsertTabs` (a data-source-only upsert doesn't touch the tabs UI or playback) and non-active tabs refetch right away (`reloadNonActiveTabs`), so switching to `Your Picks` within the same player session already shows fresh content — the active tab itself is never reloaded mid-playback, and the full rebuild on return to the screen is the catch-all
- Follow state is hydrated into the SDK right after a successful `Blaze.shared.initialize(...)` (see `BlazeSDKInteractor`) — independent of whether either screen has ever been opened

## Usage

1. Navigate to "Follow Entities (UIKit)" or "Follow Entities (SwiftUI)" from the Home screen
2. Tap the widget to open the fullscreen tabs player
3. Follow a player/team/property from within the player — watch `Your Picks` update with the new priority
