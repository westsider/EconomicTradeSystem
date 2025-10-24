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

    @State private var polygonAPIKey: String = ""
    @State private var showAPIKeyAlert = false
    @State private var hasExistingKey = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("API Configuration")) {
                    VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                        HStack {
                            Text("Polygon.io API Key")
                                .font(Constants.Typography.callout)

                            Spacer()

                            if hasExistingKey {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Constants.Colors.buyGreen)
                            }
                        }

                        if hasExistingKey {
                            Text("API key is configured")
                                .font(Constants.Typography.caption)
                                .foregroundColor(Constants.Colors.secondaryText)
                        } else {
                            SecureField("Enter API key", text: $polygonAPIKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(Constants.Typography.body)
                        }
                    }

                    if !hasExistingKey {
                        Button("Save API Key") {
                            saveAPIKey()
                        }
                        .disabled(polygonAPIKey.isEmpty)
                    } else {
                        Button("Update API Key", role: .destructive) {
                            hasExistingKey = false
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

                Section(header: Text("Indicators")) {
                    HStack {
                        Text("Bollinger Bands Period")
                        Spacer()
                        Text("\(Constants.Indicators.bollingerPeriod)")
                            .foregroundColor(Constants.Colors.secondaryText)
                    }

                    HStack {
                        Text("Bollinger Bands Std Dev")
                        Spacer()
                        Text("\(String(format: "%.1f", Constants.Indicators.bollingerStdDev))")
                            .foregroundColor(Constants.Colors.secondaryText)
                    }

                    HStack {
                        Text("RSI Period")
                        Spacer()
                        Text("\(Constants.Indicators.rsiPeriod)")
                            .foregroundColor(Constants.Colors.secondaryText)
                    }

                    HStack {
                        Text("RSI Oversold")
                        Spacer()
                        Text("\(Int(Constants.Indicators.rsiOversold))")
                            .foregroundColor(Constants.Colors.secondaryText)
                    }

                    HStack {
                        Text("RSI Overbought")
                        Spacer()
                        Text("\(Int(Constants.Indicators.rsiOverbought))")
                            .foregroundColor(Constants.Colors.secondaryText)
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
            .onAppear {
                hasExistingKey = KeychainManager.shared.hasPolygonAPIKey()
            }
        }
    }

    private func saveAPIKey() {
        viewModel.configureAPIKey(polygonAPIKey)
        hasExistingKey = true
        showAPIKeyAlert = true
        polygonAPIKey = ""
    }
}

#Preview {
    SettingsView(viewModel: SignalViewModel())
}
