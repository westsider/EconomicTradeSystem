//
//  PriceDisplayView.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import SwiftUI

struct PriceDisplayView: View {
    let signal: Signal

    var body: some View {
        VStack(spacing: Constants.Spacing.sm) {
            Text("Current Price")
                .font(Constants.Typography.headline)
                .foregroundColor(Constants.Colors.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .top, spacing: Constants.Spacing.md) {
                // Price
                VStack(alignment: .leading, spacing: 4) {
                    Text(signal.formattedPrice)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Constants.Colors.primaryText)

                    Text(signal.formattedTimestamp)
                        .font(Constants.Typography.caption)
                        .foregroundColor(Constants.Colors.secondaryText)
                }

                Spacer()

                // Distance from Bands
                VStack(alignment: .trailing, spacing: 8) {
                    distanceBadge(
                        label: "Upper BB",
                        distance: distancePercent(from: signal.indicators.bollingerUpper),
                        color: .red
                    )

                    distanceBadge(
                        label: "Middle BB",
                        distance: distancePercent(from: signal.indicators.bollingerMiddle),
                        color: .blue
                    )

                    distanceBadge(
                        label: "Lower BB",
                        distance: distancePercent(from: signal.indicators.bollingerLower),
                        color: .green
                    )
                }
            }
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.Radius.large)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func distancePercent(from band: Double) -> Double {
        ((signal.price - band) / band) * 100
    }

    private func distanceBadge(label: String, distance: Double, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(Constants.Typography.caption)
                .foregroundColor(Constants.Colors.secondaryText)

            Text(String(format: "%+.1f%%", distance))
                .font(Constants.Typography.caption)
                .fontWeight(.semibold)
                .foregroundColor(distance > 0 ? Constants.Colors.buyGreen : Constants.Colors.sellRed)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(distance > 0 ? Constants.Colors.buyGreen.opacity(0.1) : Constants.Colors.sellRed.opacity(0.1))
                )
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
        timestamp: Date(),
        symbol: "GPIX",
        type: .buy,
        price: 144.25,
        indicators: indicators,
        cycleStage: .expansion,
        reason: "Price below lower BB • RSI oversold"
    )

    PriceDisplayView(signal: signal)
        .padding()
        .background(Constants.Colors.background)
}
