//
//  PushNotificationHandler.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 27/06/2025.
//

import UIKit
import UserNotifications
import BlazeSDK

/**
 🔔 Push Notification Testing Guide:

 This class handles push notifications using UNUserNotificationCenterDelegate.

 There are two main ways to test push notifications in iOS:

 1. **Using Firebase Console**
    - Make sure Firebase is properly set up:
        - `GoogleService-Info.plist` is added to the project.
        - APNs authentication key is uploaded to Firebase.
        - `FirebaseApp.configure()` is called in AppDelegate.
    - Send test notifications via Firebase Console → Cloud Messaging.
    - Documentation: https://firebase.google.com/docs/cloud-messaging/ios/client

 2. **Using Terminal with a .apns File**
    - You can simulate remote push notifications in the iOS Simulator.
    - Example:
      ```bash
      xcrun simctl push booted com.wsc-sports.blaze-sample-ios-v2 moment_push.apns
      ```
    - Make sure the `moment_push.apns` file is in the root of your Xcode project.
 */

final class PushNotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = PushNotificationHandler()
    
    private override init() {}

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                Logger.shared.log("Error: \(error)", level: .error)
            }
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func handleDeviceToken(_ deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Logger.shared.log("Push Token: \(tokenString)")
    }
    
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: .didReceivePushNotification, object: nil, userInfo: userInfo)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        handleRemoteNotification(notification.request.content.userInfo)
        completionHandler([.badge, .sound, .banner])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handleRemoteNotification(response.notification.request.content.userInfo)
        completionHandler()
    }
}

extension Notification.Name {
    static let didReceivePushNotification = Notification.Name("didReceivePushNotification")
}
