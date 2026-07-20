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

    let initialDataState: WidgetDataState
    let styleState: WidgetLayoutStyleState

    var onApply: (WidgetDataState, WidgetLayoutStyleState) -> Void

    var body: some View {
        EditOptionsBottomSheetContainer(
            initialDataState: initialDataState,
            initialOptions: styleState,
            selectedDetent: $detentState.selected,
            onApply: { newDataState, newOptions in
                onApply(newDataState, newOptions)
                dismiss()
            }
        )
    }
}
