//
//  PaywallAlert.swift
//  blaze-sample-ios-v2
//
//  Created by Igor Yermachonak on 16/10/2026.
//

import UIKit
import BlazeSDK

/// A stand-in for your app's paywall, shown on top of the SDK's player.
enum PaywallAlert {

    static func make(for reason: BlazeContentRestrictionReason) -> UIAlertController {
        let alert = UIAlertController(
            title: title(for: reason),
            message: "Reason: \(reason.rawValue)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))

        guard canWatchWithViewerToken(reason) else { return alert }

        alert.addTextField { textField in
            textField.placeholder = "Viewer token"
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        }
        alert.addAction(UIAlertAction(title: "Watch", style: .default) { [weak alert] _ in
            guard let token = alert?.textFields?.first?.text,
                  !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            // The same viewer with a new token, so keep the content already fetched.
            // The open player asks for the item again by itself and starts playing.
            Blaze.shared.setExternalUserToken(token, cachedContentPolicy: .keep) { result in
                switch result {
                case .success:
                    Logger.shared.log("PaywallAlert - setExternalUserToken - success")
                case .failure(let error):
                    Logger.shared.log("PaywallAlert - setExternalUserToken - error: \(error.errorMessage)", level: .error)
                }
            }
        })
        return alert
    }

    private static func title(for reason: BlazeContentRestrictionReason) -> String {
        switch reason {
        case .subscriptionRequired:
            return "Subscribe to watch"
        case .externalUserTokenMissing, .externalUserTokenInvalid, .externalUserTokenExpired:
            return "Sign in to watch"
        default:
            return "This content isn't available"
        }
    }

    private static func canWatchWithViewerToken(_ reason: BlazeContentRestrictionReason) -> Bool {
        switch reason {
        case .subscriptionRequired, .externalUserTokenMissing, .externalUserTokenInvalid, .externalUserTokenExpired:
            return true
        default:
            return false
        }
    }
}
