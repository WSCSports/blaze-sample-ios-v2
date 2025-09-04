//
//  CustomizationSheetView.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 12/06/2025.
//

import SwiftUI

struct CustomizationSheetView: View {
    @Binding var options: WidgetLayoutStyleState
    var onApply: () -> Void

    @State private var draftOptions = WidgetLayoutStyleState()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 4) {
                Text("Customization examples")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("More than one option may be selected")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            Divider()

            VStack(spacing: 16) {
                checkboxRow(title: "Custom thumbnail appearance", isOn: $draftOptions.isCustomAppearance)
                checkboxRow(title: "Custom status indicator", isOn: $draftOptions.isCustomStatusIndicator)
                checkboxRow(title: "Custom title", isOn: $draftOptions.isCustomTitle)
                checkboxRow(title: "Custom badge", isOn: $draftOptions.isCustomBadge)

                Divider()

                checkboxRow(
                    title: "Custom override for a single item",
                    subTitle: "Changes will appear on the second item",
                    isOn: $draftOptions.isCustomItemStyleOverrides
                )
            }

            Divider()

            ApplyButtonView
                .padding(.top, 2)
        }
        .onAppear {
            draftOptions = options
        }
    }

    @ViewBuilder
    private func checkboxRow(
        title: String,
        subTitle: String? = nil,
        isOn: Binding<Bool>
    ) -> some View {
        Button(action: { isOn.wrappedValue.toggle() }) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isOn.wrappedValue ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.black)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                    if let subTitle = subTitle {
                        Text(subTitle)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    var ApplyButtonView: some View {
        Button("Apply") {
            options = draftOptions
            onApply()
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}
