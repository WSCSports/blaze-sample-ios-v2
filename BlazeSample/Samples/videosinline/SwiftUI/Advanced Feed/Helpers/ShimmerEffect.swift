//
//  ShimmerEffect.swift
//  BlazePrime
//
//  Created by Niko Pich on 10/08/25.
//  Copyright © 2025 com.WSCSports. All rights reserved.
//

import SwiftUI

// MARK: - Shimmer Effect Extension

@available(iOS 14.0, *)
internal struct ShimmerEffect: ViewModifier {
    @State private var isAnimating = false
    let delay: Double
    
    internal func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.white.opacity(0.4),
                                Color.clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: isAnimating ? 200 : -200)
                    .animation(
                        .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(delay),
                        value: isAnimating
                    )
            )
            .mask(content)
            .onAppear {
                isAnimating = true
            }
    }
}

@available(iOS 14.0, *)
internal extension View {
    func shimmerEffect(delay: Double = 0) -> some View {
        self.modifier(ShimmerEffect(delay: delay))
    }
}
