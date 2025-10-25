//
//  SettingsView.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SignalViewModel
    @ObservedObject var indicatorSettings = IndicatorSettings.shared

    @State private var polygonAPIKey: String = ""
    @State private var fredAPIKey: String = ""
    @State private var showAPIKeyAlert = false
    @State private var showFREDKeyAlert = false
    @State private var fredKeyAlertMessage = ""
    @State private var hasExistingPolygonKey = false
    @State private var hasExistingFREDKey = false
    @State private var showResetAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("API Configuration")) {
                    VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                        HStack {
                            Text("Polygon.io API Key")
                                .font(Constants.Typography.callout)

                            Spacer()

                            if hasExistingPolygonKey {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Constants.Colors.buyGreen)
                            }
                        }

                        if hasExistingPolygonKey {
                            Text("API key is configured")
                                .font(Constants.Typography.caption)
                                .foregroundColor(Constants.Colors.secondaryText)
                        } else {
                            SecureField("Enter API key", text: $polygonAPIKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(Constants.Typography.body)
                                .onChange(of: polygonAPIKey) { oldValue, newValue in
                                    // Automatically trim whitespace
                                    polygonAPIKey = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                                }
                        }
                    }

                    if !hasExistingPolygonKey {
                        Button("Save API Key") {
                            savePolygonAPIKey()
                        }
                        .disabled(polygonAPIKey.isEmpty)
                    } else {
                        Button("Update API Key", role: .destructive) {
                            hasExistingPolygonKey = false
                        }
                    }

                    Link(destination: URL(string: "https://polygon.io/")!) {
                        HStack {
                            Text("Get API Key at Polygon.io")
                                .font(Constants.Typography.callout)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                    }
                }

                Section(header: Text("Economic Cycle (Optional)"), footer: Text("FRED API key must be exactly 32 lowercase alphanumeric characters. App includes a free public key, but you can use your own for higher rate limits.")) {
                    VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                        HStack {
                            Text("FRED API Key")
                                .font(Constants.Typography.callout)

                            Spacer()

                            if hasExistingFREDKey {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Constants.Colors.buyGreen)
                            }
                        }

                        if hasExistingFREDKey {
                            Text("Custom API key configured")
                                .font(Constants.Typography.caption)
                                .foregroundColor(Constants.Colors.secondaryText)
                        } else {
                            TextField("Enter 32-character API key", text: $fredAPIKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(Constants.Typography.body)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .onChange(of: fredAPIKey) { oldValue, newValue in
                                    // Automatically trim whitespace
                                    fredAPIKey = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                                }

                            // Show character count and validation
                            HStack {
                                Text("Length: \(fredAPIKey.count)/32")
                                    .font(Constants.Typography.caption)
                                    .foregroundColor(fredAPIKey.count == 32 ? Constants.Colors.buyGreen : Constants.Colors.secondaryText)

                                Spacer()

                                if !fredAPIKey.isEmpty {
                                    if isValidFREDKey(fredAPIKey) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Constants.Colors.buyGreen)
                                            .font(.caption)
                                    } else {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(Constants.Colors.sellRed)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    }

                    if !hasExistingFREDKey {
                        Button("Save FRED API Key") {
                            saveFREDAPIKey()
                        }
                        .disabled(fredAPIKey.isEmpty || !isValidFREDKey(fredAPIKey))
                    } else {
                        Button("Update FRED API Key", role: .destructive) {
                            hasExistingFREDKey = false
                        }
                    }

                    Link(destination: URL(string: "https://fred.stlouisfed.org/docs/api/api_key.html")!) {
                        HStack {
                            Text("Get Free API Key at FRED")
                                .font(Constants.Typography.callout)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                    }
                }

                Section(header: Text("Trading Parameters")) {
                    HStack {
                        Text("Default Symbol")
                        Spacer()
                        Text(Constants.Trading.defaultSymbol)
                            .foregroundColor(Constants.Colors.secondaryText)
                    }

                    HStack {
                        Text("Initial Capital")
                        Spacer()
                        Text(Constants.Trading.defaultCapital.formatAsCurrency())
                            .foregroundColor(Constants.Colors.secondaryText)
                    }

                    HStack {
                        Text("Stop Loss")
                        Spacer()
                        Text("\(Int(Constants.Trading.defaultStopLossPercent * 100))%")
                            .foregroundColor(Constants.Colors.secondaryText)
                    }
                }

                Section(header: Text("Indicators"), footer: Text("Adjust technical indicator parameters. Changes apply immediately to signal generation.")) {
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

                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(Constants.Colors.secondaryText)
                    }

                    HStack {
                        Text("Update Interval")
                        Spacer()
                        Text("30 minutes")
                            .foregroundColor(Constants.Colors.secondaryText)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("API Key Saved", isPresented: $showAPIKeyAlert) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Your Polygon.io API key has been securely saved.")
            }
            .alert("FRED API Key", isPresented: $showFREDKeyAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(fredKeyAlertMessage)
            }
            .alert("Reset Indicators", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    indicatorSettings.resetToDefaults()
                    viewModel.refreshData()
                }
            } message: {
                Text("This will reset all indicator parameters to their default values. Your signals will be recalculated.")
            }
            .onAppear {
                hasExistingPolygonKey = KeychainManager.shared.hasPolygonAPIKey()
                hasExistingFREDKey = KeychainManager.shared.hasFREDAPIKey()
            }
            .onChange(of: indicatorSettings.rsiOversold) { _, _ in
                viewModel.refreshData()
            }
            .onChange(of: indicatorSettings.rsiOverbought) { _, _ in
                viewModel.refreshData()
            }
            .onChange(of: indicatorSettings.bollingerPeriod) { _, _ in
                viewModel.refreshData()
            }
            .onChange(of: indicatorSettings.bollingerStdDev) { _, _ in
                viewModel.refreshData()
            }
        }
    }

    private func savePolygonAPIKey() {
        viewModel.configureAPIKey(polygonAPIKey)
        hasExistingPolygonKey = true
        showAPIKeyAlert = true
        polygonAPIKey = ""
    }

    private func isValidFREDKey(_ key: String) -> Bool {
        // FRED keys must be exactly 32 lowercase alphanumeric characters
        return key.count == 32 &&
               key.allSatisfy { $0.isLetter || $0.isNumber } &&
               key.lowercased() == key
    }

    private func saveFREDAPIKey() {
        // Validate the key format
        guard isValidFREDKey(fredAPIKey) else {
            fredKeyAlertMessage = "Invalid FRED API key format. Key must be exactly 32 lowercase alphanumeric characters (a-z, 0-9 only).\n\nYour key has \(fredAPIKey.count) characters."
            showFREDKeyAlert = true
            return
        }

        do {
            print("💾 Saving FRED API key: \(String(fredAPIKey.prefix(8)))... (length: \(fredAPIKey.count))")
            try KeychainManager.shared.saveFREDAPIKey(fredAPIKey)
            hasExistingFREDKey = true
            fredAPIKey = ""
            fredKeyAlertMessage = "Your FRED API key has been securely saved and is now active."
            showFREDKeyAlert = true
            // Reload economic cycle with new API key
            viewModel.setupFREDService()
        } catch {
            print("❌ Failed to save FRED API key: \(error)")
            fredKeyAlertMessage = "Failed to save FRED API key: \(error.localizedDescription)"
            showFREDKeyAlert = true
        }
    }
}

#Preview {
    SettingsView(viewModel: SignalViewModel())
}
