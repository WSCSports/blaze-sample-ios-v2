import SwiftUI
import BlazeSDK

struct DefaultAppViewFactory: AppViewFactory {
    @ViewBuilder
    func makeView(for route: AppRoute) -> some View {
        switch route {
        case .start:
            HomeView()
        case .globalSettings:
            GlobalSettingsView()
        case .widgets:
            WidgetsListView()
        case .storiesRow:
            wrapped(StoriesRowViewController(), title: "Stories Row")
        case .storiesGrid:
            wrapped(StoriesGridViewController(), title: "Stories Grid")
        case .momentsRow:
            wrapped(MomentsRowViewController(), title: "Moments Row")
        case .momentsGrid:
            wrapped(MomentsGridViewController(), title: "Moments Grid")
        case .videoRow:
            wrapped(VideosRowViewController(), title: "Videos Row")
        case .videoGrid:
            wrapped(VideosGridViewController(), title: "Videos Grid")
        case .widgetsFeedDemo:
            wrapped(MixedWidgetsViewController(), title: "Widgets feed")
        case .methodsDelegates:
            wrapped(WidgetsMethodsAndDelegatesViewController(), title: "Methods & Delegates")
        case .moments:
            wrapped(MomentsContainerViewController(), title: "Moments Container")
        case .entryPoint:
            wrapped(EntryPointViewController(), title: "Entry Point")
        case .playerStyle:
            wrapped(PlayerStyleViewController(), title: "Player Style")
        case .ads:
            wrapped(AdsViewController(), title: "Ads")
        case .swiftUI:
            SwiftUIWidgetsTabView()
        case .search:
            searchView()
        case .videosInline:
            VideosInlineListView()
        case .simpleFeedExample:
            VideoPlayerExamples.SimpleFeedExample()
        case .videosFeed:
            VideosPaginatingFeedView()
        case .playerControllerExample:
            VideoPlayerExamples.PlayerControllerExample()
        }
    }

    @ViewBuilder
    private func searchView() -> some View {
        ViewControllerWrapper {
            SearchViewController(suggestionsDataSource: .labels(.singleLabel(MomentsContainerValues.momentsLabel)))
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private func wrapped(_ viewController: @autoclosure @escaping () -> UIViewController, title: String) -> some View {
        ViewControllerWrapper(viewController)
            .navigationTitle(title)
            .customBackButton()
    }
}
