//
//  AdsViewModel+BlazeGAMCustomNativeAdsDelegate.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 04/07/2025.
//

import BlazeSDK
import BlazeGAM
import GoogleInteractiveMediaAds
import GoogleMobileAds

///
/// This AdsViewModel demonstrates how to implement BlazeGAMCustomNativeAdsDelegate.
/// For more information  refer to https://dev.wsc-sports.com/docs/ios-blazegamcustomnativeadsdelegate#/
///

extension AdsViewModel {
    
    func createBlazeGAMCustomNativeDelegate() -> BlazeGAMCustomNativeAdsDelegate {
        return BlazeGAMCustomNativeAdsDelegate(
            onGAMAdError: { [weak self] error in
                self?.onGAMCustomNativeAdError(error.localizedDescription)
            },
            onGAMAdEvent: { [weak self] params in
                self?.onGAMCustomNativeAdEvent(eventType: params.eventType, adData: params.adData)
            },
            customGAMTargetingProperties: { [weak self] _ in
                self?.customGAMCustomNativeAdsProperties() ?? [:]
            },
            publisherProvidedId: { [weak self] _ in
                self?.gamCustomNativePublisherProvidedId()
            },
            networkExtras: { [weak self] _ in
                self?.gamCustomNativeNetworkExtras()
            }
        )
    }
    
    // MARK: - Event Handlers
    
    private func onGAMCustomNativeAdEvent(eventType: BlazeGoogleCustomNativeAdsHandlerEventType, adData: BlazeCustomNativeAdData) {
        Logger.shared.log("Received Custom Native Ad event of type: \(eventType), for ad:", object: adData)
    }
    
    private func onGAMCustomNativeAdError(_ error: String) {
        Logger.shared.log("Received Custom Native Ad error: \(error)", level: .error)
    }
    
    // MARK: - Configuration
    
    private func customGAMCustomNativeAdsProperties() -> [String: String] {
        return [:]
        ///
        /// For Example if you want to add consent and npa
        /// let npaKey = "npa"
        /// let gdprKey = "gdpr"
        /// return [npaKey: "0", gdprKey: "0"]
        ///
    }
    
    private func gamCustomNativePublisherProvidedId() -> String? {
        return nil
        ///
        /// For Example if you want to add publisher provided id
        /// return "custom publisher provided id"
        ///
    }
    
    private func gamCustomNativeNetworkExtras() -> Extras? {
        return nil
        ///
        /// For Example if you want to add network extras
        /// let extras = GADExtras()
        /// extras.additionalParameters = ["custom network extras string": "test",
        /// "custom network extras int": 5,
        /// "custom network extras bool": true]
        /// return extras
        ///
    }
}
