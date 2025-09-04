//
//  ViewControllerWrapper.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 19/06/2025.
//


import SwiftUI

struct ViewControllerWrapper<VC: UIViewController>: UIViewControllerRepresentable {
    let builder: () -> VC

    init(_ builder: @escaping () -> VC) {
        self.builder = builder
    }

    func makeUIViewController(context: Context) -> VC {
        return builder()
    }

    func updateUIViewController(_ uiViewController: VC, context: Context) {
        // Optional updates here
    }
}
