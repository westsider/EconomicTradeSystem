//
//  IndicatorSettingsSection.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import SwiftUI

struct IndicatorSettingsSection: View {
    @ObservedObject var indicatorSettings: IndicatorSettings
    @Binding var showResetAlert: Bool

    var body: some View {
        Section(header: Text("Indicators"), footer: Text("Adjust technical indicator parameters. Changes apply immediately to signal generation.")) {
            BollingerPeriodSlider(indicatorSettings: indicatorSettings)
            BollingerStdDevSlider(indicatorSettings: indicatorSettings)
            RSIPeriodSlider(indicatorSettings: indicatorSettings)
            RSIOversoldSlider(indicatorSettings: indicatorSettings)
            RSIOverboughtSlider(indicatorSettings: indicatorSettings)
            KeltnerPeriodSlider(indicatorSettings: indicatorSettings)
            KeltnerATRSlider(indicatorSettings: indicatorSettings)

            Button(action: {
                showResetAlert = true
            }) {
                HStack {
                    Spacer()
                    Text("Reset to Defaults")
                        .font(Constants.Typography.callout)
                    Spacer()
                }
            }
        }
    }
}

struct BollingerPeriodSlider: View {
    @ObservedObject var indicatorSettings: IndicatorSettings

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            HStack {
                Text("Bollinger Bands Period")
                    .font(Constants.Typography.callout)
                Spacer()
                Text("\(Int(indicatorSettings.bollingerPeriod))")
                    .foregroundColor(Constants.Colors.accent)
                    .font(Constants.Typography.headline)
            }
            Slider(value: $indicatorSettings.bollingerPeriod, in: 10...50, step: 1)
                .tint(Constants.Colors.accent)
        }
        .padding(.vertical, Constants.Spacing.xs)
    }
}

struct BollingerStdDevSlider: View {
    @ObservedObject var indicatorSettings: IndicatorSettings

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            HStack {
                Text("Bollinger Bands Std Dev")
                    .font(Constants.Typography.callout)
                Spacer()
                Text(String(format: "%.1f", indicatorSettings.bollingerStdDev))
                    .foregroundColor(Constants.Colors.accent)
                    .font(Constants.Typography.headline)
            }
            Slider(value: $indicatorSettings.bollingerStdDev, in: 1.0...3.0, step: 0.1)
                .tint(Constants.Colors.accent)
        }
        .padding(.vertical, Constants.Spacing.xs)
    }
}

struct RSIPeriodSlider: View {
    @ObservedObject var indicatorSettings: IndicatorSettings

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            HStack {
                Text("RSI Period")
                    .font(Constants.Typography.callout)
                Spacer()
                Text("\(Int(indicatorSettings.rsiPeriod))")
                    .foregroundColor(Constants.Colors.accent)
                    .font(Constants.Typography.headline)
            }
            Slider(value: $indicatorSettings.rsiPeriod, in: 7...21, step: 1)
                .tint(Constants.Colors.accent)
        }
        .padding(.vertical, Constants.Spacing.xs)
    }
}

struct RSIOversoldSlider: View {
    @ObservedObject var indicatorSettings: IndicatorSettings

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            HStack {
                Text("RSI Oversold")
                    .font(Constants.Typography.callout)
                Spacer()
                Text("\(Int(indicatorSettings.rsiOversold))")
                    .foregroundColor(Constants.Colors.buyGreen)
                    .font(Constants.Typography.headline)
            }
            Slider(value: $indicatorSettings.rsiOversold, in: 20...50, step: 1)
                .tint(Constants.Colors.buyGreen)
        }
        .padding(.vertical, Constants.Spacing.xs)
    }
}

struct RSIOverboughtSlider: View {
    @ObservedObject var indicatorSettings: IndicatorSettings

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            HStack {
                Text("RSI Overbought")
                    .font(Constants.Typography.callout)
                Spacer()
                Text("\(Int(indicatorSettings.rsiOverbought))")
                    .foregroundColor(Constants.Colors.sellRed)
                    .font(Constants.Typography.headline)
            }
            Slider(value: $indicatorSettings.rsiOverbought, in: 60...85, step: 1)
                .tint(Constants.Colors.sellRed)
        }
        .padding(.vertical, Constants.Spacing.xs)
    }
}

struct KeltnerPeriodSlider: View {
    @ObservedObject var indicatorSettings: IndicatorSettings

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            HStack {
                Text("Keltner Channel Period")
                    .font(Constants.Typography.callout)
                Spacer()
                Text("\(Int(indicatorSettings.keltnerPeriod))")
                    .foregroundColor(Constants.Colors.accent)
                    .font(Constants.Typography.headline)
            }
            Slider(value: $indicatorSettings.keltnerPeriod, in: 10...50, step: 1)
                .tint(Constants.Colors.accent)
        }
        .padding(.vertical, Constants.Spacing.xs)
    }
}

struct KeltnerATRSlider: View {
    @ObservedObject var indicatorSettings: IndicatorSettings

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            HStack {
                Text("Keltner ATR Multiplier")
                    .font(Constants.Typography.callout)
                Spacer()
                Text(String(format: "%.1f", indicatorSettings.keltnerATRMultiplier))
                    .foregroundColor(Constants.Colors.accent)
                    .font(Constants.Typography.headline)
            }
            Slider(value: $indicatorSettings.keltnerATRMultiplier, in: 1.0...3.0, step: 0.1)
                .tint(Constants.Colors.accent)
        }
        .padding(.vertical, Constants.Spacing.xs)
    }
}
