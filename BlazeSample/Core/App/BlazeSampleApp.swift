//
//  BlazeSampleApp.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 09/06/2025.
//

import SwiftUI

@main
struct BlazeSampleApp: App {
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AppNavigatorView(viewFactory: DefaultAppViewFactory())
        }
    }
    
    init() {
        BlazeSDKInteractor.shared.initBlazeSDK()
    }
}
