//
//  EntryPointViewController.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 25/06/2025.
//

import UIKit
import BlazeSDK

struct EntryPointDefaultValues {
    static let PUSH_INTENT_WSC_DATA_EXTRA_PARAM = "WscIasData"
    static let UNIVERSAL_LINK_SPANNABLE_TEXT = "https://your-link.com"
    static let UNIVERSAL_LINK_URI = "https://blazesample.clipro.tv/moments/684943a1a26bafd24a1f9ea9"
}

final class EntryPointViewController: UIViewController {

    private let entryPointView = EntryPointView()

    override func loadView() {
        view = entryPointView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCallbacks()
        preparePlayers()
        setPlayerState()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePushNotification(_:)),
            name: .didReceivePushNotification,
            object: nil
        )
    }

    private func setupCallbacks() {
        entryPointView.onPlayStories = { [weak self] label in
            self?.playStoriesByInput(labelExpression: label)
        }

        entryPointView.onPlayMoments = { [weak self] label in
            self?.playMomentsByInput(labelExpression: label)
        }

        entryPointView.onPlayVideos = { [weak self] label in
            self?.playVideosByInput(labelExpression: label)
        }
        
        entryPointView.onSingleStoryAction = {
            Blaze.shared.playStory("6541a24b347bb42284ddf5a4") // id of the story to play
        }
        
        entryPointView.onSingleMomentAction = {
            Blaze.shared.playMoment(for: "684943a1a26bafd24a1f9ea9", completion: nil) // id of the moment to play
        }

        entryPointView.onSingleVideoAction = {
            Blaze.shared.playVideo(for: "6801034b8c4c8e78a2e1d11b", completion: nil) // id of the video to play
        }
        
        entryPointView.onOpenLink = { [weak self] in
            self?.handleUniversalLink(universalLinkStr: EntryPointDefaultValues.UNIVERSAL_LINK_URI)
        }
    }
    
    ///
    /// Prepares the players for stories and moments by initializing the data sources and calling the prepare method.
    ///
    private func preparePlayers() {
        let storiesDataSource = BlazeDataSourceType.labels(.singleLabel(ConfigManager.storiesRowLabel))
        let momentsDataSource = BlazeDataSourceType.labels(.singleLabel(ConfigManager.momentsRowLabel))
        let videosDataSource = BlazeDataSourceType.labels(.singleLabel(ConfigManager.videosRowLabel))

        Blaze.shared.prepareStories(dataSourceType: storiesDataSource)
        Blaze.shared.prepareMoments(dataSourceType: momentsDataSource)
        Blaze.shared.prepareVideos(dataSourceType: videosDataSource)
    }

    ///
    /// Plays stories by the input label expression.
    /// For more information, refer to https://dev.wsc-sports.com/docs/ios-methods#/.
    ///
    func playStoriesByInput(labelExpression: String) {
        let storiesDataSource = BlazeDataSourceType.labels(.singleLabel(labelExpression))
        Blaze.shared.playStories(dataSourceType: storiesDataSource)
    }
    
    ///
    /// Plays stories by the input label expression.
    /// For more information, refer to https://dev.wsc-sports.com/docs/ios-methods#/.
    ///
    func playMomentsByInput(labelExpression: String) {
        let momentsDataSource = BlazeDataSourceType.labels(.singleLabel(labelExpression))
        Blaze.shared.playMoments(dataSourceType: momentsDataSource)
    }
    
    ///
    /// Plays stories by the input label expression.
    /// For more information, refer to https://dev.wsc-sports.com/docs/ios-methods#/.
    ///
    func playVideosByInput(labelExpression: String) {
        let videosDataSource = BlazeDataSourceType.labels(.singleLabel(labelExpression))
        Blaze.shared.playVideos(dataSourceType: videosDataSource)
    }
    
    ///
    /// Sets the player state.
    /// You can pause, resume, or dismiss the player.
    ///
    func setPlayerState() {
//        Blaze.shared.pauseCurrentPlayer()
//        Blaze.shared.resumeCurrentPlayer()
//        Blaze.shared.dismissCurrentPlayer()
    }
    
    ///
    /// Handles the universal link by calling BlazeSDK.handleUniversalLink.
    /// For more information, refer to https://dev.wsc-sports.com/docs/ios-methods#/
    ///
    func handleUniversalLink(universalLinkStr: String) {
        Blaze.shared.handleUniversalLink(universalLinkStr) { result in
            switch result {
            case .success:
                Logger.shared.log("Completed Successfully")
            case .failure(let error):
                Logger.shared.log("Unable to open Link: \(error)", level: .error)
            }
        }
    }
    
    ///
    /// Handles a push notification delivered via `NotificationCenter`.
    ///
    /// This method is triggered when a notification is received and posted by `PushNotificationHandler`
    /// (e.g., while the app is in the foreground or from a custom handler).
    ///
    /// If the payload is compatible with `BlazeSDK`, it will be passed to `Blaze.shared.handlePushNotificationPayload`.
    /// Otherwise, it can be processed manually for custom behavior.
    ///
    /// - Parameter notification: A `Notification` containing `userInfo` with the push payload.
    ///
    @objc private func handlePushNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        Logger.shared.log("Received push", object: userInfo)
        
        // Optional: Check if Blaze can handle the push notification before processing
        // You can also call handlePushNotificationPayload directly - it will return an error in completion block if it can't handle the payload
        if Blaze.shared.canHandlePushNotification(userInfo) {
            Blaze.shared.handlePushNotificationPayload(userInfo)
        } else {
            // Handle custom push payload
            Logger.shared.log("Custom push payload:", object: userInfo)
        }
    }
}

