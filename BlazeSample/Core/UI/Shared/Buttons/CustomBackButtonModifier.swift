//
//  CustomBackButtonModifier.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 10/06/2025.
//


import SwiftUI

struct CustomBackButtonModifier: ViewModifier {
    let color: Color
    let title: String?
    let completion: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                        completion?()
                    }) {
                        HStack(spacing: 4) {
                            Image("chevron_left")
                                .foregroundColor(color)
                            if let title = title {
                                Text(title)
                                    .foregroundColor(color)
                            }
                        }
                    }
                }
            }
    }
}

extension View {
    func customBackButton(color: Color = .black, title: String? = nil, completion: (() -> Void)? = nil) -> some View {
        self.modifier(CustomBackButtonModifier(color: color, title: title, completion: completion))
    }
}
