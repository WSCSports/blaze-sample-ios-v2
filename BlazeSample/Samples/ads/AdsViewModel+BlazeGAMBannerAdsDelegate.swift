//
//  AdsViewModel+BlazeGAMBannerAdsDelegate1.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 04/07/2025.
//

import BlazeSDK
import BlazeGAM

///
/// This AdsViewModel demonstrates how to implement BlazeGAMBannerAdsDelegate.
/// For more information refer to https://dev.wsc-sports.com/docs/ios-banner-ads#/
///

extension AdsViewModel {
    
    func createBlazeGAMBannersDelegate() -> BlazeGAMBannerAdsDelegate {
        
        let onGAMBannerAdsAdError: BlazeGAMBannerAdsDelegate.OnGAMBannerAdsAdErrorHandler = { [weak self] params in
            self?.onGAMBannersAdError(params.error.localizedDescription)
        }
        
        let onGAMBannerAdsAdEvent: BlazeGAMBannerAdsDelegate.OnGAMBannerAdsAdEventHandler = { [weak self] params in
            self?.onGAMBannersAdEvent(eventType: params.eventType, adData: params.adData)
        }
        
        return BlazeGAMBannerAdsDelegate(
            onGAMBannerAdsAdError: onGAMBannerAdsAdError,
            onGAMBannerAdsAdEvent: onGAMBannerAdsAdEvent
        )
    }
    
    private func onGAMBannersAdEvent(eventType: BlazeGAMBannerHandlerEventType, adData: BlazeGAMBannerAdsAdData) {
        Logger.shared.log("Received Banner Ad event of type: \(eventType), for ad:", object: adData)
    }
    
    private func onGAMBannersAdError(_ error: String) {
        Logger.shared.log("Received Banner Ad error: \(error)", level: .error)
    }
}
