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
    @State private var localValue: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            HStack {
                Text("Bollinger Bands Period")
                    .font(Constants.Typography.callout)
                Spacer()
                Text("\(Int(localValue))")
                    .foregroundColor(Constants.Colors.accent)
                    .font(Constants.Typography.headline)
            }
            Slider(value: $localValue, in: 10...50, step: 1, onEditingChanged: { editing in
                if !editing {
                    indicatorSettings.bollingerPeriod = localValue
                }
            })
            .tint(Constants.Colors.accent)
        }
        .padding(.vertical, Constants.Spacing.xs)
        .onAppear {
            localValue = indicatorSettings.bollingerPeriod
        }
    }
}

struct BollingerStdDevSlider: View {
    @ObservedObject var indicatorSettings: IndicatorSettings
    @State private var localValue: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            HStack {
                Text("Bollinger Bands Std Dev")
                    .font(Constants.Typography.callout)
                Spacer()
                Text(String(format: "%.1f", localValue))
                    .foregroundColor(Constants.Colors.accent)
                    .font(Constants.Typography.headline)
            }
            Slider(value: $localValue, in: 1.0...3.0, step: 0.1, onEditingChanged: { editing in
                if !editing {
                    indicatorSettings.bollingerStdDev = localValue
                }
            })
            .tint(Constants.Colors.accent)
        }
        .padding(.vertical, Constants.Spacing.xs)
        .onAppear {
            localValue = indicatorSettings.bollingerStdDev
        }
    }
}

struct RSIPeriodSlider: View {
    @ObservedObject var indicatorSettings: IndicatorSettings
    @State private var localValue: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            HStack {
                Text("RSI Period")
                    .font(Constants.Typography.callout)
                Spacer()
                Text("\(Int(localValue))")
                    .foregroundColor(Constants.Colors.accent)
                    .font(Constants.Typography.headline)
            }
            Slider(value: $localValue, in: 7...21, step: 1, onEditingChanged: { editing in
                if !editing {
                    indicatorSettings.rsiPeriod = localValue
                }
            })
            .tint(Constants.Colors.accent)
        }
        .padding(.vertical, Constants.Spacing.xs)
        .onAppear {
            localValue = indicatorSettings.rsiPeriod
        }
    }
}

struct RSIOversoldSlider: View {
    @ObservedObject var indicatorSettings: IndicatorSettings
    @State private var localValue: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            HStack {
                Text("RSI Oversold")
                    .font(Constants.Typography.callout)
                Spacer()
                Text("\(Int(localValue))")
                    .foregroundColor(Constants.Colors.buyGreen)
                    .font(Constants.Typography.headline)
            }
            Slider(value: $localValue, in: 20...50, step: 1, onEditingChanged: { editing in
                if !editing {
                    indicatorSettings.rsiOversold = localValue
                }
            })
            .tint(Constants.Colors.buyGreen)
        }
        .padding(.vertical, Constants.Spacing.xs)
        .onAppear {
            localValue = indicatorSettings.rsiOversold
        }
    }
}

struct RSIOverboughtSlider: View {
    @ObservedObject var indicatorSettings: IndicatorSettings
    @State private var localValue: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            HStack {
                Text("RSI Overbought")
                    .font(Constants.Typography.callout)
                Spacer()
                Text("\(Int(localValue))")
                    .foregroundColor(Constants.Colors.sellRed)
                    .font(Constants.Typography.headline)
            }
            Slider(value: $localValue, in: 60...85, step: 1, onEditingChanged: { editing in
                if !editing {
                    indicatorSettings.rsiOverbought = localValue
                }
            })
            .tint(Constants.Colors.sellRed)
        }
        .padding(.vertical, Constants.Spacing.xs)
        .onAppear {
            localValue = indicatorSettings.rsiOverbought
        }
    }
}

struct KeltnerPeriodSlider: View {
    @ObservedObject var indicatorSettings: IndicatorSettings
    @State private var localValue: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            HStack {
                Text("Keltner Channel Period")
                    .font(Constants.Typography.callout)
                Spacer()
                Text("\(Int(localValue))")
                    .foregroundColor(Constants.Colors.accent)
                    .font(Constants.Typography.headline)
            }
            Slider(value: $localValue, in: 10...50, step: 1, onEditingChanged: { editing in
                if !editing {
                    indicatorSettings.keltnerPeriod = localValue
                }
            })
            .tint(Constants.Colors.accent)
        }
        .padding(.vertical, Constants.Spacing.xs)
        .onAppear {
            localValue = indicatorSettings.keltnerPeriod
        }
    }
}

struct KeltnerATRSlider: View {
    @ObservedObject var indicatorSettings: IndicatorSettings
    @State private var localValue: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            HStack {
                Text("Keltner ATR Multiplier")
                    .font(Constants.Typography.callout)
                Spacer()
                Text(String(format: "%.1f", localValue))
                    .foregroundColor(Constants.Colors.accent)
                    .font(Constants.Typography.headline)
            }
            Slider(value: $localValue, in: 1.0...3.0, step: 0.1, onEditingChanged: { editing in
                if !editing {
                    indicatorSettings.keltnerATRMultiplier = localValue
                }
            })
            .tint(Constants.Colors.accent)
        }
        .padding(.vertical, Constants.Spacing.xs)
        .onAppear {
            localValue = indicatorSettings.keltnerATRMultiplier
        }
    }
}
