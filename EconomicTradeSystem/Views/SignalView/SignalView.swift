//
//  SignalView.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import SwiftUI

struct SignalView: View {
    @ObservedObject var viewModel: SignalViewModel
    @State private var showSettings = false
    @State private var cachedBollingerBands: [(upper: Double, middle: Double, lower: Double)] = []
    @State private var cachedRSI: [Double] = []

    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()

                if viewModel.isLoading && viewModel.currentSignal == nil {
                    ProgressView("Loading signal data...")
                        .font(Constants.Typography.body)
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage, onRetry: {
                        Task {
                            await viewModel.fetchLatestData()
                        }
                    })
                } else {
                    ScrollView {
                        VStack(spacing: Constants.Spacing.lg) {
                            // Signal Circle (replaces signal card)
                            if let signal = viewModel.currentSignal {
                                SignalCircleView(
                                    signal: signal.type.rawValue,
                                    subtitle: signal.formattedPrice
                                )
                            }

                            // Economic Cycle Button (replaces cycle badge)
                            if let cycleStage = viewModel.cycleStage {
                                ExpansionButton(
                                    title: cycleStage.rawValue,
                                    gradient: cycleGradient(for: cycleStage)
                                )
                            }

                            // Symbol Picker
                            SymbolPickerView(selectedSymbol: $viewModel.selectedSymbol)

                            // Charts Section
                            if !viewModel.priceBars.isEmpty && !cachedBollingerBands.isEmpty && !cachedRSI.isEmpty {
                                // Price Chart with Bollinger Bands
                                PriceChartView(priceBars: viewModel.priceBars, indicators: cachedBollingerBands)

                                // RSI Chart
                                RSIChartView(priceBars: viewModel.priceBars, rsiValues: cachedRSI)
                            } else if !viewModel.priceBars.isEmpty {
                                // Show loading while calculating indicators
                                ProgressView("Calculating indicators...")
                                    .padding()
                            }

                            // Last Update Time
                            if let lastUpdate = viewModel.lastUpdateTime {
                                Text("Updated: \(lastUpdate.formatAsDateTime())")
                                    .font(Constants.Typography.caption)
                                    .foregroundColor(Constants.Colors.secondaryText)
                                    .padding(.top, Constants.Spacing.sm)
                            }
                        }
                        .padding(Constants.Spacing.md)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("\(viewModel.selectedSymbol) Signals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gear")
                            .foregroundColor(Constants.Colors.accent)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel)
            }
            .task {
                await viewModel.fetchLatestData()
                viewModel.startAutoUpdate()
            }
            .onDisappear {
                viewModel.stopAutoUpdate()
            }
            .onChange(of: viewModel.selectedSymbol) { oldValue, newValue in
                if oldValue != newValue {
                    viewModel.changeSymbol(to: newValue)
                }
            }
            .onChange(of: viewModel.priceBars.count) { oldValue, newValue in
                // Recalculate indicators when price bars count changes (data updated)
                if !viewModel.priceBars.isEmpty {
                    let start = Date()
                    print("⏱️ [SignalView] Recalculating indicators for \(viewModel.priceBars.count) bars")
                    cachedBollingerBands = IndicatorCalculator.calculateBollingerBands(bars: viewModel.priceBars)
                    cachedRSI = IndicatorCalculator.calculateRSI(bars: viewModel.priceBars)
                    print("⏱️ [SignalView] Indicators calculated in \(Date().timeIntervalSince(start))s")
                }
            }
            .onAppear {
                // Initial calculation
                if !viewModel.priceBars.isEmpty {
                    let start = Date()
                    print("⏱️ [SignalView] Initial indicator calculation for \(viewModel.priceBars.count) bars")
                    cachedBollingerBands = IndicatorCalculator.calculateBollingerBands(bars: viewModel.priceBars)
                    cachedRSI = IndicatorCalculator.calculateRSI(bars: viewModel.priceBars)
                    print("⏱️ [SignalView] Initial calculation completed in \(Date().timeIntervalSince(start))s")
                }
            }
        }
    }

    // Helper function to create gradient for cycle stages
    private func cycleGradient(for stage: CycleStage) -> Gradient {
        switch stage {
        case .expansion:
            return Gradient(colors: [
                Color(red: 0.38, green: 0.93, blue: 0.78),
                Color(red: 0.10, green: 0.80, blue: 0.47)
            ])
        case .peak:
            return Gradient(colors: [
                Color(red: 1.0, green: 0.65, blue: 0.0),
                Color(red: 1.0, green: 0.45, blue: 0.0)
            ])
        case .contraction:
            return Gradient(colors: [
                Color(red: 1.0, green: 0.30, blue: 0.30),
                Color(red: 0.90, green: 0.10, blue: 0.10)
            ])
        case .recovery:
            return Gradient(colors: [
                Color(red: 0.0, green: 0.60, blue: 0.95),
                Color(red: 0.0, green: 0.45, blue: 0.85)
            ])
        }
    }
}

#Preview {
    SignalView(viewModel: SignalViewModel())
}
