//
//  EditSourceSheetView.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 13/06/2025.
//

import SwiftUI
import BlazeSDK

struct EditSourceSheetView: View {
    @Binding var dataState: WidgetDataState

    var onApply: () -> Void

    @State private var draftExample: DataSourceExample = .labels
    @State private var draftOrderType: BlazeOrderType = .manual

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TitleView

            VStack(spacing: 18) {
                DataSourceExamplesView
                OrderTypeView
                ApplyButtonView
            }
        }
        .onAppear {
            draftExample = dataState.selectedExample
            draftOrderType = dataState.orderType
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

    // Each option maps to a different data source example - see WidgetDataState.toDataSource()
    var DataSourceExamplesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Data source example")
                .font(.system(size: 14, weight: .medium))

            ForEach(DataSourceExample.allCases, id: \.self) { option in
                Button {
                    draftExample = option
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: draftExample == option ? "largecircle.fill.circle" : "circle")
                            .foregroundColor(draftExample == option ? .black : .gray)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(option.rawValue)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            Text(option.description)
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }

            Divider()
                .padding(.top, 10)
        }
    }

    var OrderTypeView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Order type (Labels and IDs only)")
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
            dataState.selectedExample = draftExample
            dataState.orderType = draftOrderType
            onApply()
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}
