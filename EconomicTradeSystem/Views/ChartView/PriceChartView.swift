//
//  PriceChartView.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import SwiftUI
import Charts

struct PriceChartView: View {
    let priceBars: [PriceBar]
    let indicators: [(upper: Double, middle: Double, lower: Double)]

    private var chartData: [ChartDataPoint] {
        var data: [ChartDataPoint] = []
        for (index, bar) in priceBars.enumerated() {
            if index < indicators.count {
                let indicator = indicators[index]
                data.append(ChartDataPoint(
                    timestamp: bar.timestamp,
                    close: bar.close,
                    bbUpper: indicator.upper,
                    bbMiddle: indicator.middle,
                    bbLower: indicator.lower
                ))
            }
        }
        return data
    }

    private var visibleData: [ChartDataPoint] {
        // Show last 100 bars for better visibility
        Array(chartData.suffix(100))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Price & Bollinger Bands")
                .font(Constants.Typography.headline)
                .foregroundColor(Constants.Colors.primaryText)
                .padding(.horizontal, Constants.Spacing.md)

            Chart(visibleData) { dataPoint in
                // Bollinger Band Upper
                LineMark(
                    x: .value("Time", dataPoint.timestamp),
                    y: .value("Upper BB", dataPoint.bbUpper)
                )
                .foregroundStyle(Constants.Colors.sellRed.opacity(0.6))
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 3]))

                // Bollinger Band Middle (SMA)
                LineMark(
                    x: .value("Time", dataPoint.timestamp),
                    y: .value("Middle BB", dataPoint.bbMiddle)
                )
                .foregroundStyle(Constants.Colors.accent.opacity(0.6))
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 3]))

                // Bollinger Band Lower
                LineMark(
                    x: .value("Time", dataPoint.timestamp),
                    y: .value("Lower BB", dataPoint.bbLower)
                )
                .foregroundStyle(Constants.Colors.buyGreen.opacity(0.6))
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 3]))

                // Price Line
                LineMark(
                    x: .value("Time", dataPoint.timestamp),
                    y: .value("Price", dataPoint.close)
                )
                .foregroundStyle(Constants.Colors.primaryText)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 6)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour().minute())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .frame(height: 250)
            .padding(.horizontal, Constants.Spacing.sm)

            // Legend
            HStack(spacing: Constants.Spacing.md) {
                LegendItem(color: Constants.Colors.primaryText, label: "Price", style: .solid)
                LegendItem(color: Constants.Colors.sellRed, label: "Upper BB", style: .dashed)
                LegendItem(color: Constants.Colors.accent, label: "Middle BB", style: .dashed)
                LegendItem(color: Constants.Colors.buyGreen, label: "Lower BB", style: .dashed)
            }
            .padding(.horizontal, Constants.Spacing.md)
        }
        .padding(.vertical, Constants.Spacing.md)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.Radius.large)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let close: Double
    let bbUpper: Double
    let bbMiddle: Double
    let bbLower: Double
}

struct LegendItem: View {
    let color: Color
    let label: String
    let style: LineStyle

    enum LineStyle {
        case solid, dashed
    }

    var body: some View {
        HStack(spacing: 4) {
            if style == .solid {
                Rectangle()
                    .fill(color)
                    .frame(width: 16, height: 2)
            } else {
                HStack(spacing: 2) {
                    Rectangle()
                        .fill(color)
                        .frame(width: 4, height: 2)
                    Rectangle()
                        .fill(color)
                        .frame(width: 4, height: 2)
                }
            }

            Text(label)
                .font(Constants.Typography.caption)
                .foregroundColor(Constants.Colors.secondaryText)
        }
    }
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

    let indicators = IndicatorCalculator.calculateBollingerBands(bars: bars)

    PriceChartView(priceBars: bars, indicators: indicators)
        .padding()
        .background(Constants.Colors.background)
}
