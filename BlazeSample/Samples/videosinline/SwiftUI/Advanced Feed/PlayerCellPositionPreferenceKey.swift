//
//  PlayerCellPositionPreferenceKey.swift
//  BlazePrime
//
//  Created by Niko Pich on 10/08/25.
//  Copyright © 2025 com.WSCSports. All rights reserved.
//

import SwiftUI

// MARK: - Cell Position Tracking

internal struct PlayerCellPositionPreferenceKey: PreferenceKey {
    struct CellPosition: Equatable {
        let id: String
        let frame: CGRect
    }
    
    static var defaultValue: [CellPosition] = []
    
    static func reduce(value: inout [CellPosition], nextValue: () -> [CellPosition]) {
        value.append(contentsOf: nextValue())
    }
}
