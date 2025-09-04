//
//  PrimaryButtonStyle.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 10/06/2025.
//


import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .frame(height: 42)
            .background(Color.black.opacity(configuration.isPressed ? 0.7 : 1))
            .cornerRadius(8)
    }
}
