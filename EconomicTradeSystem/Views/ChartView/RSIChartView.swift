//
//  RSIChartView.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import SwiftUI
import Charts

struct RSIChartView: View {
    let priceBars: [PriceBar]
    let rsiValues: [Double]

    @ObservedObject var indicatorSettings = IndicatorSettings.shared

    private var chartData: [(bar: PriceBar, rsi: Double)] {
        var data: [(bar: PriceBar, rsi: Double)] = []
        for (index, bar) in priceBars.enumerated() {
            if index < rsiValues.count {
                data.append((bar: bar, rsi: rsiValues[index]))
            }
        }
        return data
    }

    private var visibleData: [(bar: PriceBar, rsi: Double)] {
        // Show last 100 bars to match price chart
        Array(chartData.suffix(100))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            HStack {
//                Text("RSI (Relative Strength Index)")
//                    .font(Constants.Typography.headline)
//                    .foregroundColor(Constants.Colors.primaryText)
//
               Spacer()

                if let currentRSI = rsiValues.last {
                    Text("RSI \(Int(currentRSI))")
                        .font(Constants.Typography.title3)
                        .fontWeight(.bold)
                        .foregroundColor(rsiColor(currentRSI))
                }
            }
            .padding(.horizontal, Constants.Spacing.md)

            Chart {
                // Overbought line (dynamic threshold)
                RuleMark(y: .value("Overbought", indicatorSettings.rsiOverbought))
                    .foregroundStyle(Constants.Colors.sellRed.opacity(0.2))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 2]))

                // Oversold line (dynamic threshold)
                RuleMark(y: .value("Oversold", indicatorSettings.rsiOversold))
                    .foregroundStyle(Constants.Colors.buyGreen.opacity(0.2))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 2]))

                // RSI Line with continuous index (no gaps)
                ForEach(Array(visibleData.enumerated()), id: \.offset) { offset, data in
                    LineMark(
                        x: .value("Index", offset),
                        y: .value("RSI", data.rsi)
                    )
                    .foregroundStyle(rsiColor(data.rsi))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
            }
            .chartYScale(domain: 0...100)
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(position: .trailing, values: [Int(indicatorSettings.rsiOversold), 50, Int(indicatorSettings.rsiOverbought)]) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2]))
                        .foregroundStyle(Constants.Colors.secondaryText.opacity(0.2))
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
            .frame(height: 100)
            .padding(.horizontal, Constants.Spacing.sm)

            // Simplified legend with dynamic thresholds
            HStack(spacing: Constants.Spacing.md) {
                Text("Overbought >\(Int(indicatorSettings.rsiOverbought))")
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.secondaryText)

                Text("•")
                    .foregroundColor(Constants.Colors.secondaryText)

                Text("Oversold <\(Int(indicatorSettings.rsiOversold))")
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.secondaryText)
            }
            .padding(.horizontal, Constants.Spacing.md)
        }
        .padding(.vertical, Constants.Spacing.md)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.Radius.large)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func rsiColor(_ rsi: Double) -> Color {
        if rsi < indicatorSettings.rsiOversold {
            return Constants.Colors.buyGreen
        } else if rsi > indicatorSettings.rsiOverbought {
            return Constants.Colors.sellRed
        } else {
            return Constants.Colors.accent
        }
    }
}

struct RSIDataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let rsi: Double
}

#Preview {
    let bars = (0..<50).map { i in
        PriceBar(
            timestamp: Date().addingTimeInterval(TimeInterval(i * 1800)),
            open: 150.0 + Double.random(in: -5...5),
            high: 155.0 + Double.random(in: -5...5),
            low: 145.0 + Double.random(in: -5...5),
            close: 150.0 + Double.random(in: -5...5),
            volume: 1000000
        )
    }

    let rsiValues = IndicatorCalculator.calculateRSI(bars: bars)

    RSIChartView(priceBars: bars, rsiValues: rsiValues)
        .padding()
        .background(Constants.Colors.background)
}
