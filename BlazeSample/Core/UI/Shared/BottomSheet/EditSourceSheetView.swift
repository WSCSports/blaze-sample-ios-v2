//
//  EditSourceSheetView.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 13/06/2025.
//

import SwiftUI
import BlazeSDK

struct EditSourceSheetView: View {
    @Binding var label: String
    @Binding var orderType: BlazeOrderType

    var onApply: () -> Void

    @State private var draftLabel: String = ""
    @State private var draftOrderType: BlazeOrderType = .manual

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TitleView

            VStack(spacing: 18) {
                LabelView
                OrderTypeView
                ApplyButtonView
            }
        }
        .onAppear {
            draftLabel = label
            draftOrderType = orderType
        }
    }

    var TitleView: some View {
        HStack {
            Spacer()
            Text("Edit source data")
                .font(.system(size: 16, weight: .medium))
            Spacer()
        }
    }

    var LabelView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Label")
                .font(.system(size: 14, weight: .medium))

            TextField("Label", text: $draftLabel)
                .font(.system(size: 14, weight: .medium))
                .padding(8)
                .frame(height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )

            Divider()
                .padding(.top, 10)
        }
    }

    var OrderTypeView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Order type")
                .font(.system(size: 14, weight: .medium))

            Menu {
                ForEach(BlazeOrderType.allCases.reversed(), id: \.self) { option in
                    Button {
                        draftOrderType = option
                    } label: {
                        Text(option.rawValue)
                            .font(.system(size: 13))
                    }
                }
            } label: {
                HStack {
                    Text(draftOrderType.rawValue)
                        .foregroundColor(.black)
                        .font(.system(size: 14))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding(8)
                .frame(height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
            }

            Divider()
                .padding(.top, 10)
        }
    }

    var ApplyButtonView: some View {
        Button("Apply") {
            label = draftLabel
            orderType = draftOrderType
            onApply()
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}
