//
//  ListItemView.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 10/06/2025.
//

import SwiftUI


struct ListItemView: View {
    let item: ListItem

    var body: some View {
        HStack(spacing: 0) {
            if item.icon != nil {
                VStack {
                    Image(item.icon ?? "")
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                        .frame(width: 24)
                    Spacer()
                }
                .padding(.leading, 8)
                .padding(.trailing, 8)
            } else {
                Spacer()
                    .frame(width: 16)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                Text(item.subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 5)
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .padding(.trailing, 16)
        }
//        .padding(8)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
