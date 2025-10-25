//
//  SymbolPickerView.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import SwiftUI

struct SymbolPickerView: View {
    @Binding var selectedSymbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Select Symbol")
                .font(Constants.Typography.callout)
                .foregroundColor(Constants.Colors.secondaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.sm) {
                    ForEach(Constants.Trading.availableSymbols, id: \.self) { symbol in
                        SymbolButton(
                            symbol: symbol,
                            isSelected: selectedSymbol == symbol,
                            action: {
                                selectedSymbol = symbol
                            }
                        )
                    }
                }
            }
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.Radius.large)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct SymbolButton: View {
    let symbol: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(symbol)
                .font(Constants.Typography.headline)
                .fontWeight(isSelected ? .bold : .semibold)
                .foregroundColor(isSelected ? .white : Constants.Colors.secondaryText)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: Constants.Radius.medium)
                        .fill(isSelected ? Constants.Colors.accent : Color(hex: "#E8E8ED"))
                )
        }
    }
}

#Preview {
    SymbolPickerView(selectedSymbol: .constant("GPIX"))
        .padding()
        .background(Constants.Colors.background)
}
