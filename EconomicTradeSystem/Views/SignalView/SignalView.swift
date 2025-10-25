//
//  SignalView.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import SwiftUI

struct SignalView: View {
    @StateObject private var viewModel = SignalViewModel()
    @State private var showSettings = false

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
                            // Symbol Picker
                            SymbolPickerView(selectedSymbol: $viewModel.selectedSymbol)
                                .onChange(of: viewModel.selectedSymbol) { newSymbol in
                                    viewModel.changeSymbol(to: newSymbol)
                                }

                            // Signal Card
                            if let signal = viewModel.currentSignal {
                                SignalCardView(signal: signal, position: viewModel.currentPosition)
                            }

                            // Economic Cycle Badge
                            if let cycleStage = viewModel.cycleStage {
                                CycleBadgeView(stage: cycleStage)
                            }

                            // Price Display
                            if let signal = viewModel.currentSignal {
                                PriceDisplayView(signal: signal)
                            }

                            // Position Info (if open)
                            if let position = viewModel.currentPosition {
                                PositionCardView(position: position, currentPrice: viewModel.currentSignal?.price ?? 0)
                            }

                            // Charts Section
                            if !viewModel.priceBars.isEmpty {
                                // Price Chart with Bollinger Bands
                                let bollingerBands = IndicatorCalculator.calculateBollingerBands(bars: viewModel.priceBars)
                                PriceChartView(priceBars: viewModel.priceBars, indicators: bollingerBands)

                                // RSI Chart
                                let rsiValues = IndicatorCalculator.calculateRSI(bars: viewModel.priceBars)
                                RSIChartView(priceBars: viewModel.priceBars, rsiValues: rsiValues)
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
        }
    }
}

#Preview {
    SignalView()
}
