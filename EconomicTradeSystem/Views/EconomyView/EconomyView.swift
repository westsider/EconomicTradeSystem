//
//  EconomyView.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/25/25.
//

import SwiftUI

struct EconomyView: View {
    @ObservedObject var viewModel: SignalViewModel
    @State private var spyBars: [PriceBar] = []
    @State private var isLoadingSPY = false
    @State private var isLoadingEconomicData = false

    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()

                if isLoadingEconomicData && viewModel.cycleStage == nil {
                    VStack(spacing: Constants.Spacing.md) {
                        ProgressView()
                        Text("Loading economic data...")
                            .font(Constants.Typography.body)
                            .foregroundColor(Constants.Colors.secondaryText)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: Constants.Spacing.lg) {
                            // Current Cycle Stage Card
                            if let cycleStage = viewModel.cycleStage {
                                CycleStageCard(stage: cycleStage)
                            } else {
                                // Placeholder while loading
                                VStack(spacing: Constants.Spacing.md) {
                                    ProgressView()
                                    Text("Analyzing economic cycle...")
                                        .font(Constants.Typography.callout)
                                        .foregroundColor(Constants.Colors.secondaryText)
                                }
                                .frame(height: 150)
                                .frame(maxWidth: .infinity)
                                .background(Constants.Colors.cardBackground)
                                .cornerRadius(Constants.Radius.large)
                            }

                            // Economic Indicators Grid
                            if let economicData = viewModel.currentEconomicData {
                                EconomicIndicatorsGrid(data: economicData)
                            } else {
                                // Placeholder while loading
                                VStack(spacing: Constants.Spacing.md) {
                                    ProgressView()
                                    Text("Loading economic indicators...")
                                        .font(Constants.Typography.callout)
                                        .foregroundColor(Constants.Colors.secondaryText)
                                }
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .background(Constants.Colors.cardBackground)
                                .cornerRadius(Constants.Radius.large)
                            }

                            // S&P 500 Chart with Cycle Background
                            if !spyBars.isEmpty {
                                SPYCycleChartView(
                                    priceBars: spyBars,
                                    cycleStages: viewModel.cycleStageHistory
                                )
                            } else if isLoadingSPY {
                                VStack(spacing: Constants.Spacing.md) {
                                    ProgressView()
                                    Text("Loading S&P 500 data...")
                                        .font(Constants.Typography.callout)
                                        .foregroundColor(Constants.Colors.secondaryText)
                                }
                                .frame(height: 300)
                                .frame(maxWidth: .infinity)
                                .background(Constants.Colors.cardBackground)
                                .cornerRadius(Constants.Radius.large)
                            }

                            // Cycle Description
                            if let cycleStage = viewModel.cycleStage {
                                CycleDescriptionCard(stage: cycleStage)
                            }
                        }
                        .padding(Constants.Spacing.md)
                    }
                }
            }
            .navigationTitle("Economic Cycle")
            .navigationBarTitleDisplayMode(.large)
            .task {
                isLoadingEconomicData = true
                await loadSPYData()
                isLoadingEconomicData = false
            }
            .refreshable {
                await loadSPYData()
            }
        }
    }

    private func loadSPYData() async {
        guard let polygonService = viewModel.polygonService else { return }

        isLoadingSPY = true
        do {
            // Fetch 2 years of daily SPY bars
            let bars = try await polygonService.fetchDailyBars(symbol: "SPY", daysBack: 730)
            spyBars = bars
        } catch {
            print("Failed to load SPY data: \(error)")
        }
        isLoadingSPY = false
    }
}

// MARK: - Cycle Stage Card
struct CycleStageCard: View {
    let stage: CycleStage

    var body: some View {
        VStack(spacing: Constants.Spacing.md) {
            Text("Current Economic Cycle")
                .font(Constants.Typography.headline)
                .foregroundColor(Constants.Colors.secondaryText)

            HStack {
                Image(systemName: stage.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                Text(stage.rawValue)
                    .font(Constants.Typography.largeTitle)
                    .foregroundColor(.white)
            }
            .padding(Constants.Spacing.lg)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: stage.gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(Constants.Radius.large)
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.Radius.large)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Economic Indicators Grid
struct EconomicIndicatorsGrid: View {
    let data: EconomicData

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Economic Indicators")
                .font(Constants.Typography.headline)
                .foregroundColor(Constants.Colors.primaryText)
                .padding(.horizontal, Constants.Spacing.md)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Constants.Spacing.sm) {
                if let gdp = data.gdpGrowth {
                    IndicatorCard(
                        title: "GDP Growth",
                        value: "\(String(format: "%.1f", gdp))%",
                        icon: "chart.line.uptrend.xyaxis",
                        color: gdp >= 0 ? Constants.Colors.buyGreen : Constants.Colors.sellRed
                    )
                }

                if let unemployment = data.unemployment {
                    IndicatorCard(
                        title: "Unemployment",
                        value: "\(String(format: "%.1f", unemployment))%",
                        icon: "person.2.fill",
                        color: unemployment < 5 ? Constants.Colors.buyGreen : Constants.Colors.sellRed
                    )
                }

                if let inflation = data.inflation {
                    IndicatorCard(
                        title: "Inflation",
                        value: "\(String(format: "%.1f", inflation))%",
                        icon: "dollarsign.circle.fill",
                        color: inflation < 3 ? Constants.Colors.buyGreen : Constants.Colors.sellRed
                    )
                }

                if let yieldCurve = data.yieldCurve {
                    IndicatorCard(
                        title: "Yield Curve",
                        value: "\(String(format: "%.2f", yieldCurve))%",
                        icon: "chart.xyaxis.line",
                        color: yieldCurve >= 0 ? Constants.Colors.buyGreen : Constants.Colors.sellRed
                    )
                }

                if let fedFunds = data.fedFunds {
                    IndicatorCard(
                        title: "Fed Funds Rate",
                        value: "\(String(format: "%.2f", fedFunds))%",
                        icon: "building.columns.fill",
                        color: Constants.Colors.accent
                    )
                }

                if let sentiment = data.consumerSentiment {
                    IndicatorCard(
                        title: "Consumer Sentiment",
                        value: "\(String(format: "%.0f", sentiment))",
                        icon: "person.3.fill",
                        color: sentiment > 80 ? Constants.Colors.buyGreen : Constants.Colors.sellRed
                    )
                }
            }
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.Radius.large)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Indicator Card
struct IndicatorCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }

            Text(title)
                .font(Constants.Typography.caption)
                .foregroundColor(Constants.Colors.secondaryText)

            Text(value)
                .font(Constants.Typography.title3)
                .fontWeight(.bold)
                .foregroundColor(Constants.Colors.primaryText)
        }
        .padding(Constants.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Constants.Colors.background)
        .cornerRadius(Constants.Radius.medium)
    }
}

// MARK: - Cycle Description Card
struct CycleDescriptionCard: View {
    let stage: CycleStage

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("What does \(stage.rawValue) mean?")
                .font(Constants.Typography.headline)
                .foregroundColor(Constants.Colors.primaryText)

            Text(stage.description)
                .font(Constants.Typography.body)
                .foregroundColor(Constants.Colors.secondaryText)
                .lineSpacing(4)

            Divider()

            Text("Trading Strategy")
                .font(Constants.Typography.headline)
                .foregroundColor(Constants.Colors.primaryText)

            Text(stage.tradingStrategy)
                .font(Constants.Typography.body)
                .foregroundColor(Constants.Colors.secondaryText)
                .lineSpacing(4)
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.Radius.large)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    EconomyView(viewModel: SignalViewModel())
}
