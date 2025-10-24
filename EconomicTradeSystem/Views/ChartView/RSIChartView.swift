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

    private var chartData: [RSIDataPoint] {
        var data: [RSIDataPoint] = []
        for (index, bar) in priceBars.enumerated() {
            if index < rsiValues.count {
                data.append(RSIDataPoint(
                    timestamp: bar.timestamp,
                    rsi: rsiValues[index]
                ))
            }
        }
        return data
    }

    private var visibleData: [RSIDataPoint] {
        // Show last 100 bars to match price chart
        Array(chartData.suffix(100))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("RSI (Relative Strength Index)")
                .font(Constants.Typography.headline)
                .foregroundColor(Constants.Colors.primaryText)
                .padding(.horizontal, Constants.Spacing.md)

            Chart {
                // Overbought line (70)
                RuleMark(y: .value("Overbought", 70))
                    .foregroundStyle(Constants.Colors.sellRed.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))

                // Oversold line (30)
                RuleMark(y: .value("Oversold", 30))
                    .foregroundStyle(Constants.Colors.buyGreen.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))

                // Middle line (50)
                RuleMark(y: .value("Middle", 50))
                    .foregroundStyle(Constants.Colors.secondaryText.opacity(0.2))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [2, 2]))

                // RSI Line
                ForEach(visibleData) { dataPoint in
                    LineMark(
                        x: .value("Time", dataPoint.timestamp),
                        y: .value("RSI", dataPoint.rsi)
                    )
                    .foregroundStyle(rsiColor(dataPoint.rsi))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }

                // RSI Area Fill
                ForEach(visibleData) { dataPoint in
                    AreaMark(
                        x: .value("Time", dataPoint.timestamp),
                        yStart: .value("Zero", 50),
                        yEnd: .value("RSI", dataPoint.rsi)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [rsiColor(dataPoint.rsi).opacity(0.3), rsiColor(dataPoint.rsi).opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .chartYScale(domain: 0...100)
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 6)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour().minute())
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 30, 50, 70, 100]) { value in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .frame(height: 150)
            .padding(.horizontal, Constants.Spacing.sm)

            // Legend with current RSI
            HStack(spacing: Constants.Spacing.md) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Constants.Colors.sellRed.opacity(0.3))
                        .frame(width: 8, height: 8)
                    Text("Overbought (>70)")
                        .font(Constants.Typography.caption)
                        .foregroundColor(Constants.Colors.secondaryText)
                }

                HStack(spacing: 4) {
                    Circle()
                        .fill(Constants.Colors.buyGreen.opacity(0.3))
                        .frame(width: 8, height: 8)
                    Text("Oversold (<30)")
                        .font(Constants.Typography.caption)
                        .foregroundColor(Constants.Colors.secondaryText)
                }

                Spacer()

                if let currentRSI = rsiValues.last {
                    HStack(spacing: 4) {
                        Text("Current:")
                            .font(Constants.Typography.caption)
                            .foregroundColor(Constants.Colors.secondaryText)
                        Text("\(Int(currentRSI))")
                            .font(Constants.Typography.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(rsiColor(currentRSI))
                    }
                }
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
