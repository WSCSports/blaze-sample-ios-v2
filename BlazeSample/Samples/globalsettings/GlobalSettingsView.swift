//
//  GlobalSettingsView.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 10/06/2025.
//

import SwiftUI
import BlazeSDK

struct GlobalSettingsView: View {
    
    @State private var doNotTrackUser = Blaze.shared.doNotTrackUser
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 38) {
                Toggle(isOn: $doNotTrackUser) {
                    Text("Do not track user")
                        .font(.system(size: 14, weight: .bold))
                }
                
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("External user ID")
                        .font(.system(size: 14, weight: .bold))
                    
                    LabeledTextFieldWithButton(
                        placeholder: "Enter external user ID",
                        buttonTitle: "Submit"
                    ) { userId in
                        setExternalUserId(userId)
                    }
                }
                
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Geo location")
                        .font(.system(size: 14, weight: .bold))

                    LabeledTextFieldWithButton(
                        placeholder: "Enter Geo location",
                        buttonTitle: "Submit"
                    ) { location in
                        setGeoLocation(location)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Global Settings")
        .customBackButton()
        .onChange(of: doNotTrackUser) { newValue in
            updateUserTrackStatus()
        }
    }
    
    ///Set external user id for BlazeSDK.
    ///
    ///More information about external user id can be found in the documentation
    ///https://dev.wsc-sports.com/docs/ios-methods#external-user
    private func setExternalUserId(_ userId: String) {
        Blaze.shared.setExternalUserId(userId) { result in
            switch result {
            case .success:
                Logger.shared.log("GlobalSettingsView - setExternalUserId - success")
            case .failure(let error):
                Logger.shared.log("GlobalSettingsView - setExternalUserId - error: \(error)", level: .error)
            }
        }
    }
    

    ///Set geo restriction for BlazeSDK.
    ///
    ///More information about geo location can be found in the documentation
    ///https://dev.wsc-sports.com/docs/ios-methods#geo-location-///restrictions
    private func setGeoLocation(_ location: String) {
        do {
            try Blaze.shared.updateGeo(location)
            Logger.shared.log("GlobalSettingsView - updateGeo - success")
        } catch {
            Logger.shared.log("GlobalSettingsView - updateGeo - error: \(error)", level: .error)
        }
    }
    
    
    /// Optional - Set default style for Blaze players.
    /// If not implemented, the default style will be BlazeStoryPlayerStyle.base(),  BlazeMomentsPlayerStyle.base() and BlazeVideosPlayerStyle.base()
    ///
    /// More information about Blaze players style customization can be found in the documentation
    /// https://dev.wsc-sports.com/docs/ios-blaze-story-player-style/
    /// https://dev.wsc-sports.com/docs/ios-blaze-moments-player-style/
    /// https://dev.wsc-sports.com/docs/ios-blazevideosplayerstyle/
    private func setDefaultPlayersStyle() {
        var storyPlayerStyle = BlazeStoryPlayerStyle.base()
        storyPlayerStyle.backgroundColor = UIColor(named: "black") ?? .black
        storyPlayerStyle.title.textColor = UIColor(named: "wsc_accent") ?? .systemBlue
        storyPlayerStyle.title.font = .systemFont(ofSize: 16)
        Blaze.shared.setDefaultStoryPlayerStyle(storyPlayerStyle)
        
        
        var momentsPlayerStyle = BlazeMomentsPlayerStyle.base()
        momentsPlayerStyle.backgroundColor = UIColor(named: "black") ?? .black
        momentsPlayerStyle.headingText.font = .systemFont(ofSize: 22)
        momentsPlayerStyle.bodyText.font = .systemFont(ofSize: 18)
        Blaze.shared.setDefaultMomentsPlayerStyle(momentsPlayerStyle)
        
        var videosPlayerStyle = BlazeVideosPlayerStyle.base()
        videosPlayerStyle.backgroundColor = UIColor(named: "black") ?? .black
        videosPlayerStyle.headingText.font = .systemFont(ofSize: 22)
        Blaze.shared.setDefaultVideosPlayerStyle(videosPlayerStyle)
    }
    
    /// Updates the user tracking preference in BlazeSDK.
    /// Set `doNotTrackUser` to `true` to disable user tracking (default is `false`).
    ///
    /// See the documentation for more information:
    /// https://dev.wsc-sports.com/docs/ios-methods#donottrackuser
    func updateUserTrackStatus() {
        Blaze.shared.doNotTrackUser = doNotTrackUser
    }
}


#Preview {
    GlobalSettingsView()
}
