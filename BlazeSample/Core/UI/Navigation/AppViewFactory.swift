//
//  AppViewFactory.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 10/06/2025.
//

import SwiftUI

protocol AppViewFactory {
    associatedtype V: View
    @ViewBuilder func makeView(for route: AppRoute) -> V
}
