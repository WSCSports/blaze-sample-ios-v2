//
//  WidgetsDelegate.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 04/07/2025.
//

import Foundation
import BlazeSDK

final class WidgetsDelegate {
    
    /// Creates a BlazeWidgetDelegate with standard logging functionality and custom onDataLoadComplete callback
    /// - Parameters:
    ///   - identifier: Optional identifier for the widget (used in logs)
    ///   - onDataLoadComplete: Optional additional callback for data load completion
    /// - Returns: Configured BlazeWidgetDelegate
    static func create(
        identifier: String? = nil,
        onDataLoadComplete: (() -> Void)? = nil
    ) -> BlazeWidgetDelegate {
        return BlazeWidgetDelegate(
            onDataLoadStarted: { params in
                let logIdentifier = identifier ?? "Unknown"
                Logger.shared.log("[\(logIdentifier)] Widget data load started - Widget: \(params.sourceId ?? "unknown"), Type: \(params.playerType)")
            },
            onDataLoadComplete: { params in
                let logIdentifier = identifier ?? "Unknown"
                
                // Call custom callback first
                onDataLoadComplete?()
                
                switch params.result {
                case .success():
                    Logger.shared.log("[\(logIdentifier)] Widget data load complete - Widget: \(params.sourceId ?? "unknown"), Items: \(params.itemsCount)")
                case .failure(let error):
                    Logger.shared.log("[\(logIdentifier)] Widget data load error - Widget: \(params.sourceId ?? "unknown"), Error: \(error.errorMessage)", level: .error)
                }
            },
            onPlayerDidAppear: { params in
                let logIdentifier = identifier ?? "Unknown"
                Logger.shared.log("[\(logIdentifier)] Player appeared - Widget: \(params.sourceId ?? "unknown"), Type: \(params.playerType)")
            },
            onPlayerDidDismiss: { params in
                let logIdentifier = identifier ?? "Unknown"
                Logger.shared.log("[\(logIdentifier)] Player dismissed - Widget: \(params.sourceId ?? "unknown"), Type: \(params.playerType)")
            },
            onTriggerCTA: { params in
                let logIdentifier = identifier ?? "Unknown"
                Logger.shared.log("[\(logIdentifier)] CTA triggered - Widget: \(params.sourceId ?? "unknown"), Action: \(params.actionType), Param: \(params.actionParam)")
                // Return false to use default behavior
                return false
            },
            onTriggerCustomActionButton: { params in
                let logIdentifier = identifier ?? "Unknown"
                Logger.shared.log("[\(logIdentifier)] Custom action triggered - Widget: \(params.sourceId ?? "unknown"), Button: \(params.customActionParams)", object: params.customActionParams)
            }
        )
    }
} 
