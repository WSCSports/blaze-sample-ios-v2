//
//  AdsViewModel.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 04/07/2025.
//

import Foundation
import BlazeSDK
import BlazeGAM
import BlazeIMA
import GoogleInteractiveMediaAds
import GoogleMobileAds

class AdsViewModel {
    
    lazy var widgetDelegate: BlazeWidgetDelegate = WidgetsDelegate.create(identifier: "Ads")
    private lazy var gamCustomNativeDelegate = createBlazeGAMCustomNativeDelegate()
    private lazy var gamBannersDelegate = createBlazeGAMBannersDelegate()
    private lazy var imaDelegate = createBlazeIMADelegate()
    
    deinit {
        disableBlazeSDKAds()
    }
    
    ///
    /// Enable Blaze SDK ads.
    /// Note: Ads can also be enabled in the SDK.init() completion block.
    /// Once enabled, they remain active for the entire app lifecycle.
    ///
    func enableBlazeSDKAds() {
        BlazeGAM.shared
            .enableCustomNativeAds(
                defaultCustomNativeAdsConfig: .init(
                    adUnit: ConfigManager.adUnit,
                    templateId: ConfigManager.templateId
                ),
                delegate: gamCustomNativeDelegate
            )
        
        BlazeIMA.shared.enableAds(delegate: imaDelegate)
        BlazeGAM.shared.enableBannerAds(delegate: gamBannersDelegate)
    }
    
    ///
    /// Optional - Disable Blaze SDK ads.
    /// Ads can be disabled at any time, not necessarily in deinit.
    /// To re-enable the ads, simply call the enableBlazeSDKAds() method.
    /// 
    private func disableBlazeSDKAds() {
        BlazeIMA.shared.disableAds()
        BlazeGAM.shared.disableCustomNativeAds()
        BlazeGAM.shared.disableBannerAds()
    }
}
