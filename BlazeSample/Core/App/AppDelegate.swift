//
//  AppDelegate.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 27/06/2025.
//

import UIKit
import Firebase
import FirebaseMessaging

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Should be uncommentd once push notifications are setted up in the Fireabse Console
//        FirebaseApp.configure()
        PushNotificationHandler.shared.registerForPushNotifications()
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        PushNotificationHandler.shared.handleDeviceToken(deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Logger.shared.log("Failed to register: \(error)", level: .error)
    }
}
