//
//  SignalCardView.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import SwiftUI

struct SignalCardView: View {
    let signal: Signal
    let position: Position?

    var body: some View {
        VStack(spacing: Constants.Spacing.md) {
            // Signal Header
            HStack {
                Image(systemName: signal.type.icon)
                    .font(.system(size: 40))
                    .foregroundColor(signal.type.color)

                VStack(alignment: .leading, spacing: 4) {
                    Text(signal.type.rawValue)
                        .font(Constants.Typography.title)
                        .fontWeight(.bold)
                        .foregroundColor(signal.type.color)

                    Text(signal.symbol)
                        .font(Constants.Typography.title3)
                        .foregroundColor(Constants.Colors.secondaryText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(signal.formattedPrice)
                        .font(Constants.Typography.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.primaryText)

                    Text(signal.formattedTimestamp)
                        .font(Constants.Typography.caption)
                        .foregroundColor(Constants.Colors.secondaryText)
                }
            }

            Divider()

            // Signal Reason
            HStack(alignment: .top, spacing: Constants.Spacing.sm) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(Constants.Colors.accent)
                    .font(Constants.Typography.callout)

                Text(signal.reason)
                    .font(Constants.Typography.callout)
                    .foregroundColor(Constants.Colors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }

            // Technical Indicators
            VStack(spacing: Constants.Spacing.sm) {
                IndicatorRow(
                    label: "RSI",
                    value: "\(Int(signal.indicators.rsi))",
                    color: rsiColor(signal.indicators.rsi)
                )

                IndicatorRow(
                    label: "BB Upper",
                    value: signal.indicators.bollingerUpper.formatAsCurrency(),
                    color: Constants.Colors.secondaryText
                )

                IndicatorRow(
                    label: "BB Middle",
                    value: signal.indicators.bollingerMiddle.formatAsCurrency(),
                    color: Constants.Colors.secondaryText
                )

                IndicatorRow(
                    label: "BB Lower",
                    value: signal.indicators.bollingerLower.formatAsCurrency(),
                    color: Constants.Colors.secondaryText
                )

                if signal.indicators.isSqueeze {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Squeeze Detected")
                            .font(Constants.Typography.callout)
                            .foregroundColor(.orange)
                        Spacer()
                    }
                }
            }
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.Radius.large)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func rsiColor(_ rsi: Double) -> Color {
        if rsi < 30 {
            return Constants.Colors.buyGreen
        } else if rsi > 70 {
            return Constants.Colors.sellRed
        } else {
            return Constants.Colors.secondaryText
        }
    }
}

struct IndicatorRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(Constants.Typography.callout)
                .foregroundColor(Constants.Colors.secondaryText)
            Spacer()
            Text(value)
                .font(Constants.Typography.callout)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

#Preview {
    let indicators = TechnicalIndicators(
        bollingerUpper: 155.50,
        bollingerMiddle: 150.00,
        bollingerLower: 144.50,
        rsi: 28.5,
        keltnerUpper: 154.00,
        keltnerLower: 146.00
    )

    let signal = Signal(
        timestamp: Date(),
        symbol: "GPIX",
        type: .buy,
        price: 144.25,
        indicators: indicators,
        cycleStage: .expansion,
        reason: "Price 0.2% below lower BB • RSI oversold at 28"
    )

    SignalCardView(signal: signal, position: nil)
        .padding()
        .background(Constants.Colors.background)
}
