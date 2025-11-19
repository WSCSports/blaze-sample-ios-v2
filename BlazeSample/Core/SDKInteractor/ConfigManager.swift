//
//  ConfigManager.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 23/06/2025.
//


import Foundation

/*
  Configuration keys prefixed with "BLAZE_" are automatically injected from the
  corresponding .xcconfig file (e.g., AppConfig.xcconfig), linked in the Xcode Build Settings.
*/

enum ConfigManager {
    
    static var blazeApiKey: String {
        getValue(for: "BLAZE_API_KEY")
    }
    
    static var storiesRowLabel: String {
        getValue(for: "BLAZE_STORIES_ROW_LABEL")
    }

    static var storiesGridLabel: String {
        getValue(for: "BLAZE_STORIES_GRID_LABEL")
    }

    static var momentsRowLabel: String {
        getValue(for: "BLAZE_MOMENTS_ROW_LABEL")
    }

    static var momentsGridLabel: String {
        getValue(for: "BLAZE_MOMENTS_GRID_LABEL")
    }

    static var videosGridLabel: String {
        getValue(for: "BLAZE_VIDEOS_GRID_LABEL")
    }

    static var videosRowLabel: String {
        getValue(for: "BLAZE_VIDEOS_ROW_LABEL")
    }

    static var videoInlineLabel: String {
        getValue(for: "BLAZE_VIDEO_INLINE_LABEL")
    }

    static var momentsContainerTabLabel: String {
        getValue(for: "BLAZE_MOMENTS_CONTAINER_TAB_LABEL")
    }

    static var adUnit: String {
        getValue(for: "BLAZE_AD_UNIT")
    }

    static var templateId: String {
        getValue(for: "BLAZE_TEMPLATE_ID")
    }

    static var defaultCacheSize: Int {
        Int(getValue(for: "BLAZE_CACHE_SIZE")) ?? 500
    }
    
    static var storiesAdsCustomNativeLabel: String {
        getValue(for: "BLAZE_STORIES_ADS_CUSTOM_NATIVE_LABEL")
    }

    static var storiesAdsBannerLabel: String {
        getValue(for: "BLAZE_STORIES_ADS_BANNER_LABEL")
    }
    
    static var momentContainerLabel1: String {
        getValue(for: "BLAZE_MOMENTS_CONTAINER_LABEL_1")
    }
    
    static var momentContainerLabel2: String {
        getValue(for: "BLAZE_MOMENTS_CONTAINER_LABEL_2")
    }

    private static func getValue(for key: String) -> String {
        guard let value = Bundle.main.infoDictionary?[key] as? String else {
            fatalError("Missing config value for key: \(key)")
        }
        return value
    }
}
