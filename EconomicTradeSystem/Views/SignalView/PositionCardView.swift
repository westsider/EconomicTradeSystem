//
//  PositionCardView.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import SwiftUI

struct PositionCardView: View {
    let position: Position
    let currentPrice: Double

    private var currentProfitLoss: Double {
        (currentPrice - position.entryPrice) * position.shares
    }

    private var currentProfitLossPercent: Double {
        ((currentPrice - position.entryPrice) / position.entryPrice) * 100
    }

    private var isProfit: Bool {
        currentProfitLoss > 0
    }

    var body: some View {
        VStack(spacing: Constants.Spacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Open Position")
                        .font(Constants.Typography.headline)
                        .foregroundColor(Constants.Colors.primaryText)

                    Text(position.symbol)
                        .font(Constants.Typography.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.accent)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(currentProfitLoss.formatAsCurrency())
                        .font(Constants.Typography.title3)
                        .fontWeight(.bold)
                        .foregroundColor(isProfit ? Constants.Colors.buyGreen : Constants.Colors.sellRed)

                    Text(String(format: "%+.2f%%", currentProfitLossPercent))
                        .font(Constants.Typography.callout)
                        .foregroundColor(isProfit ? Constants.Colors.buyGreen : Constants.Colors.sellRed)
                }
            }

            Divider()

            // Position Details
            VStack(spacing: Constants.Spacing.sm) {
                PositionRow(label: "Entry Price", value: position.entryPrice.formatAsCurrency())
                PositionRow(label: "Current Price", value: currentPrice.formatAsCurrency())
                PositionRow(label: "Shares", value: String(format: "%.2f", position.shares))
                PositionRow(label: "Entry Value", value: position.entryValue.formatAsCurrency())
                PositionRow(label: "Current Value", value: (currentPrice * position.shares).formatAsCurrency())

                Divider()

                PositionRow(
                    label: "Stop Loss",
                    value: position.stopLoss.formatAsCurrency(),
                    valueColor: Constants.Colors.sellRed
                )

                let distanceToStop = ((currentPrice - position.stopLoss) / currentPrice) * 100
                HStack {
                    Text("Distance to Stop")
                        .font(Constants.Typography.callout)
                        .foregroundColor(Constants.Colors.secondaryText)
                    Spacer()
                    Text(String(format: "%.1f%%", distanceToStop))
                        .font(Constants.Typography.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(distanceToStop < 5 ? Constants.Colors.sellRed : Constants.Colors.secondaryText)
                }
            }

            // Entry Signal Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Entry Signal")
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.secondaryText)

                Text(position.entrySignal.reason)
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Text(position.entryDate.formatAsDateTime())
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Constants.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Constants.Radius.large)
                .fill(Constants.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.Radius.large)
                        .stroke(Constants.Colors.accent.opacity(0.3), lineWidth: 2)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct PositionRow: View {
    let label: String
    let value: String
    var valueColor: Color = Constants.Colors.primaryText

    var body: some View {
        HStack {
            Text(label)
                .font(Constants.Typography.callout)
                .foregroundColor(Constants.Colors.secondaryText)
            Spacer()
            Text(value)
                .font(Constants.Typography.callout)
                .fontWeight(.semibold)
                .foregroundColor(valueColor)
        }
    }
}

#Preview {
    let indicators = TechnicalIndicators(
        bollingerUpper: 155.50,
        bollingerMiddle: 150.00,
        bollingerLower: 144.50,
        rsi: 28.5
    )

    let signal = Signal(
        timestamp: Date().addingTimeInterval(-3600),
        symbol: "GPIX",
        type: .buy,
        price: 144.25,
        indicators: indicators,
        cycleStage: .expansion,
        reason: "Price 0.2% below lower BB • RSI oversold at 28"
    )

    let position = Position(
        symbol: "GPIX",
        entryDate: signal.timestamp,
        entryPrice: signal.price,
        entrySignal: signal,
        shares: 207.9,
        stopLoss: 141.37
    )

    PositionCardView(position: position, currentPrice: 147.50)
        .padding()
        .background(Constants.Colors.background)
}
