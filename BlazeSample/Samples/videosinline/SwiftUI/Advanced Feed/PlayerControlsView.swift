//
//  PlayerControlsView.swift
//  BlazePrime
//
//  Created by Niko Pich on 10/08/25.
//  Copyright © 2025 com.WSCSports. All rights reserved.
//

import SwiftUI
import BlazeSDK

// MARK: - Player Controls Demo View

@available(iOS 14.0, *)
internal struct PlayerControlsView: View {
    @ObservedObject var playerController: BlazeSwiftUIVideoInlinePlayerController
    
    internal var body: some View {
        VStack(spacing: 8) {
            Text("@StateObject Controller")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                // Play/Pause Controls
                Button("⏸️ Pause") {
                    playerController.pausePlayer()
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(4)
                
                Button("▶️ Resume") {
                    playerController.resumePlayer()
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .foregroundColor(.green)
                .cornerRadius(4)
                
                // Full Screen Control
                Button("⛶ Full Screen") {
                    playerController.enterFullScreen()
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(4)
            }
            
            HStack(spacing: 12) {
                // Interaction Controls
                Button("🚫 Block") {
                    playerController.blockInteraction()
                }
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(3)
                
                Button("✅ Unblock") {
                    playerController.unblockInteraction()
                }
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.green.opacity(0.1))
                .foregroundColor(.green)
                .cornerRadius(3)
                
//                Button("🔄 Reset") {
//                    playerController.resetToPlaceholder()
//                }
//                .font(.caption2)
//                .padding(.horizontal, 6)
//                .padding(.vertical, 3)
//                .background(Color.orange.opacity(0.1))
//                .cornerRadius(3)
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal, 8)
    }
}
