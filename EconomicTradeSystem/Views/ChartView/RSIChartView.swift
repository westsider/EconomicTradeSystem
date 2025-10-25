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
                Text("RSI (Relative Strength Index)")
                    .font(Constants.Typography.headline)
                    .foregroundColor(Constants.Colors.primaryText)

                Spacer()

                if let currentRSI = rsiValues.last {
                    Text("\(Int(currentRSI))")
                        .font(Constants.Typography.title3)
                        .fontWeight(.bold)
                        .foregroundColor(rsiColor(currentRSI))
                }
            }
            .padding(.horizontal, Constants.Spacing.md)

            Chart {
                // Overbought line (70)
                RuleMark(y: .value("Overbought", 70))
                    .foregroundStyle(Constants.Colors.sellRed.opacity(0.2))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 2]))

                // Oversold line (30)
                RuleMark(y: .value("Oversold", 30))
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
                AxisMarks(position: .trailing, values: [30, 50, 70]) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2]))
                        .foregroundStyle(Constants.Colors.secondaryText.opacity(0.2))
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
            .frame(height: 100)
            .padding(.horizontal, Constants.Spacing.sm)

            // Simplified legend
            HStack(spacing: Constants.Spacing.md) {
                Text("Overbought >70")
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.secondaryText)

                Text("•")
                    .foregroundColor(Constants.Colors.secondaryText)

                Text("Oversold <30")
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
        if rsi < 30 {
            return Constants.Colors.buyGreen
        } else if rsi > 70 {
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
