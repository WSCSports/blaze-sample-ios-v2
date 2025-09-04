//
//  BottomSheetContainerWrapper.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 13/06/2025.
//

import SwiftUI
import BlazeSDK

final class DetentState: ObservableObject {
    @Published var selected: UISheetPresentationController.Detent.Identifier = .init(EditOptionSheetContent.mainMenu.rawValue)
}

struct BottomSheetContainerWrapper: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject var detentState: DetentState

    let initialLabel: String
    let initialOrderType: BlazeOrderType
    let styleState: WidgetLayoutStyleState

    var onApply: (String, BlazeOrderType, WidgetLayoutStyleState) -> Void

    var body: some View {
        EditOptionsBottomSheetContainer(
            initialLabel: initialLabel,
            initialOrderType: initialOrderType,
            initialOptions: styleState,
            selectedDetent: $detentState.selected,
            onApply: { newLabel, newOrder, newOptions in
                onApply(newLabel, newOrder, newOptions)
                dismiss()
            }
        )
    }
}
