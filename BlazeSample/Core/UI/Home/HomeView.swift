//
//  ContentView.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 09/06/2025.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var coordinator: AppNavigationCoordinator
    
    let items: [ListItem] = [
        .init(icon: "settings", title: "Global Settings", subtitle: "Set global SDK properties", route: .globalSettings),
        .init(icon: "widgets", title: "Widgets", subtitle: "Browse widgets and customization examples", route: .widgets),
        .init(icon: "moments", title: "Moment container", subtitle: "Embed and manage moments in your app", route: .moments),
        .init(icon: "entryPoint", title: "Entry point", subtitle: "Deeplink handling", route: .entryPoint),
        .init(icon: "playerStyle", title: "Player style", subtitle: "Explore options and customizations", route: .playerStyle),
        .init(icon: "ads", title: "Ads", subtitle: "SDK integration of custom native and IMA ads", route: .ads),
        .init(icon: "swiftUI", title: "SwiftUI", subtitle: "SwiftUI widgets implementation", route: .swiftUI),
    ]
    
    var body: some View {
        ZStack {
            GradientView
            VStack(alignment: .leading, spacing: 0) {
                HeaderView
                ContenView
            }
        }
    }
    
    var ContenView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(items) { item in
                    Button(action: {
                        coordinator.push(item.route)
                    }, label: {
                        ListItemView(item: item)
                    })
                }
            }
            .padding()
        }
    }
    
    var HeaderView: some View {
        HStack {
            Image("logo")
            Spacer()
        }
        .padding()
    }
    
    var GradientView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "#E5FF00"),
                Color(hex: "#F2FF80"),
                Color.white
            ]),
            startPoint: .top,
            endPoint: UnitPoint(x: 0.5, y: 0.7)
        )
        .ignoresSafeArea()
    }
}

#Preview {
    HomeView()
}
