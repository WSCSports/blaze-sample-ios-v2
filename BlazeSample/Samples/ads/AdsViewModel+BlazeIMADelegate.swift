//
//  AdsViewModel+BlazeIMADelegate.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 04/07/2025.
//

import BlazeSDK
import BlazeIMA
import GoogleInteractiveMediaAds
import GoogleMobileAds

///
/// This AdsViewModel demonstrates how to implement BlazeGAMCustomNativeAdsDelegate.
/// For more information  refer to https://dev.wsc-sports.com/docs/ios-ima-module#/
///

extension AdsViewModel {
    
    func createBlazeIMADelegate() -> BlazeIMADelegate {
        
        let onImAAdError: BlazeIMADelegate.OnIMAAdErrorHandler = { [weak self] error in
            self?.onIMAAdError(error)
        }
        
        let onImAAdEvent: BlazeIMADelegate.OnIMAAdEventHandler = { [weak self] params in
            self?.onIMAAdEvent(eventType: params.eventType, adInfo: params.adInfo)
        }
        
        let additionalIMATagQueryParams: BlazeIMADelegate.AdditionalIMATagQueryParamsHandler = { [weak self] params in
            self?.adExtraParams() ?? [:]
        }
        
        let customIMASettings: BlazeIMADelegate.CustomIMASettingsHandler = { [weak self] params in
            self?.customIMASettings()
        }
        
        let overrideAdTagUrl: BlazeIMADelegate.OverrideAdTagUrlHandler = { [weak self] params in
            self?.overrideAdTagUrl()
        }
        
        return BlazeIMADelegate(
            onIMAAdError: onImAAdError,
            onIMAAdEvent: onImAAdEvent,
            additionalIMATagQueryParams: additionalIMATagQueryParams,
            customIMASettings: customIMASettings,
            overrideAdTagUrl: overrideAdTagUrl
        )
    }
    
    private func onIMAAdEvent(eventType: BlazeIMAHandlerEventType, adInfo: BlazeImaAdInfo) {
        Logger.shared.log("Received Ad event of type: \(eventType), for ad:", object: adInfo)
    }
    
    private func onIMAAdError(_ error: String) {
        Logger.shared.log("Received Ad error: \(error)", level: .error)
    }
    
    private func adExtraParams() -> [String: String] {
        return [:]
        ///
        /// For Example if you want to add consent and npa
        /// let npaKey = "npa"
        /// let gdprKey = "gdpr"
        /// return [npaKey: "0", gdprKey: "0"]
        ///
    }
    
    private func customIMASettings() -> IMASettings {
        let imaSettings = IMASettings()
        /// For example if you want to change the ima language
        /// imaSettings.language = "es"
        return imaSettings
    }
    
    private func overrideAdTagUrl() -> String? {
        return nil
        ///For example if you want to override the ad tag url
       /// return "overrideAdTagUrl"
    }
}
