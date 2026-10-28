//
//  ContentRestrictionHandler.swift
//  blaze-sample-ios-v2
//
//  Created by Igor Yermachonak on 16/10/2026.
//

import UIKit
import BlazeSDK

/// The one place the sample decides what happens when the viewer isn't allowed to watch an item.
/// Every delegate in the sample forwards `onContentRestricted` here.
enum ContentRestrictionHandler {

    typealias Params = (
        playerType: BlazePlayerType,
        sourceId: String?,
        reason: BlazeContentRestrictionReason,
        contentParams: BlazeRestrictedContentParams
    )

    private static weak var presentedPaywall: UIViewController?

    static func onContentRestricted(_ params: Params) -> BlazeContentRestrictionHandleType {
        Logger.shared.log(
            "onContentRestricted - playerType: \(params.playerType), sourceId: \(params.sourceId ?? "nil"), reason: \(params.reason.rawValue), contentId: \(params.contentParams.contentId), contentIndex: \(params.contentParams.contentIndex)"
        )
        // The SDK's player is presented on top of the app, so the paywall is presented on top of the player.
        DispatchQueue.main.async {
            presentPaywall(for: params.reason)
        }
        // The app shows its own paywall.
        return .handledByApp
    }

    private static func presentPaywall(for reason: BlazeContentRestrictionReason) {
        guard presentedPaywall == nil, let topViewController = topViewController() else { return }
        let paywall = PaywallAlert.make(for: reason)
        presentedPaywall = paywall

        // The player may still be animating in, for example when it was opened from an entry point.
        if let transitionCoordinator = topViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: nil) { _ in
                (self.topViewController() ?? topViewController).present(paywall, animated: true)
            }
        } else {
            topViewController.present(paywall, animated: true)
        }
    }

    private static func topViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
        var topViewController = keyWindow?.rootViewController
        while let presented = topViewController?.presentedViewController {
            topViewController = presented
        }
        return topViewController
    }
}
