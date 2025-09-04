//
//  BlazeSDKInteractor.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 19/07/2023.
//

import Foundation
import BlazeSDK
import UIKit
import BlazeGAM
import BlazeIMA
import GoogleInteractiveMediaAds
import GoogleMobileAds

/*
  Configuration keys prefixed with "BLAZE_" are automatically injected from the
  corresponding .xcconfig file (e.g., AppConfig.xcconfig), linked in the Xcode Build Settings.
*/

final class BlazeSDKInteractor {
    
    static var shared: BlazeSDKInteractor = BlazeSDKInteractor()
    
    private let blazeSdk = Blaze.shared
    
    func initBlazeSDK() {
        blazeSdk.initialize(
            apiKey: ConfigManager.blazeApiKey,
            cachingSize: ConfigManager.defaultCacheSize,
            prefetchingPolicy: .Default,
            geo: nil
        ) { [weak self] result in
            self?.handleBlazeSdkInitializedResult(for: result)
        }
        
        setupBlazeGlobalDelegate()
    }
    
    private func handleBlazeSdkInitializedResult(for result: BlazeResult) {
        switch result {
        case .success:
            Logger.shared.log("SKD initialized successfully!")
        case .failure(let error):
            Logger.shared.log("Error message in blaze sdk: \(error.errorMessage)", level: .error)
        }
    }
    
    private func setupBlazeGlobalDelegate() {
        blazeSdk.delegate.onEventTriggered = onEventTriggered()
        blazeSdk.delegate.onErrorThrown = { [weak self] error in
            self?.onErrorThrown(error)
        }
    }
}

// MARK: - BlazeSDKDelegate Handlers
extension BlazeSDKInteractor {
    func onEventTriggered() -> BlazeSDKDelegate.OnEventTriggeredHandler {
        { eventData in
            Logger.shared.log("onEventTriggered", object: eventData)
        }
    }
    
    func onErrorThrown(_ error: BlazeError) {
        Logger.shared.log("\(error.errorMessage)", level: .error)
    }
}
