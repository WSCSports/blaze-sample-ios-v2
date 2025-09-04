//
//  BottomSheetContainer.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 13/06/2025.
//

import SwiftUI
import BlazeSDK

extension BlazeOrderType: @retroactive CaseIterable {
    public static var allCases: [BlazeOrderType] = [
        .manual,
        .recentlyUpdatedFirst,
        .recentlyUpdatedLast,
        .aToZ,
        .zToA,
        .recentlyCreatedFirst,
        .recentlyCreatedLast,
        .random
    ]
}

enum EditOptionSheetContent: String {
    case mainMenu, editSource, customization
}

struct WidgetLayoutStyleState: Equatable {
    var isCustomAppearance: Bool = false
    var isCustomStatusIndicator: Bool = false
    var isCustomTitle: Bool = false
    var isCustomBadge: Bool = false
    var isCustomItemStyleOverrides: Bool = false
}

struct EditOptionsBottomSheetContainer: View {

    @State private var sheetContent: EditOptionSheetContent = .mainMenu
    @State var draftLabel: String
    @State var draftOrderType: BlazeOrderType
    @State var draftOptions: WidgetLayoutStyleState
    @Binding var selectedDetent: UISheetPresentationController.Detent.Identifier
    
    let onApply: (String, BlazeOrderType, WidgetLayoutStyleState) -> Void

    init(
        initialLabel: String,
        initialOrderType: BlazeOrderType,
        initialOptions: WidgetLayoutStyleState,
        selectedDetent: Binding<UISheetPresentationController.Detent.Identifier>,
        onApply: @escaping (String, BlazeOrderType, WidgetLayoutStyleState) -> Void
    ) {
        self._draftLabel = .init(initialValue: initialLabel)
        self._draftOrderType = .init(initialValue: initialOrderType)
        self._draftOptions = .init(initialValue: initialOptions)
        self._selectedDetent = selectedDetent
        self.onApply = onApply
    }
    
    var body: some View {
        Group {
            switch sheetContent {
            case .mainMenu:
                MainMenu
                    .onAppear { selectedDetent = .init(EditOptionSheetContent.mainMenu.rawValue) }

            case .editSource:
                EditSourceSheetView(
                    label: $draftLabel,
                    orderType: $draftOrderType,
                    onApply: applyAndDismiss
                )
                .onAppear { selectedDetent = .init(EditOptionSheetContent.editSource.rawValue) }
            case .customization:
                CustomizationSheetView(
                    options: $draftOptions,
                    onApply: applyAndDismiss
                )
                .onAppear { selectedDetent = .init(EditOptionSheetContent.customization.rawValue) }
            }
        }
        .presentationDragIndicator(.visible)
        .padding(.horizontal, 24)
    }

    private func applyAndDismiss() {
        onApply(draftLabel, draftOrderType, draftOptions)
    }

    var MainMenu: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            actionButton(
                title: "Edit data source",
                subtitle: "Configure the data source and display order"
            ) {
                sheetContent = .editSource
                withAnimation {
                    sheetContent = .editSource
                    selectedDetent = .init("editSource")
                }
            }
            
            Divider()
                .padding(.vertical, 4)
            
            actionButton(
                title: "Customization examples",
                subtitle: "Demo of some available custom options"
            ) {
                sheetContent = .customization
            }
        }
    }
    
    @ViewBuilder
    func actionButton(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }

                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.trailing, 20)
            }
        }
    }
}
