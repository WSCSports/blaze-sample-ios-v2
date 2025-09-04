//
//  LabeledTextFieldWithButton.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 10/06/2025.
//

import SwiftUI

struct LabeledTextFieldWithButton: View {
    let placeholder: String
    let buttonTitle: String
    var onSubmit: (String) -> Void

    @State private var text: String = ""

    var body: some View {
        VStack(spacing: 16) {
            TextField(placeholder, text: $text)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .frame(height: 42)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black)
                )

            Button(action: {
                onSubmit(text)
            }) {
                Text(buttonTitle)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}
