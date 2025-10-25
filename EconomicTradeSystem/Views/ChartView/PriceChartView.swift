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

    private var chartData: [(bar: PriceBar, indicator: (upper: Double, middle: Double, lower: Double), index: Int)] {
        var data: [(bar: PriceBar, indicator: (upper: Double, middle: Double, lower: Double), index: Int)] = []
        for (index, bar) in priceBars.enumerated() {
            if index < indicators.count {
                data.append((bar: bar, indicator: indicators[index], index: index))
            }
        }
        return data
    }

    private var visibleData: [(bar: PriceBar, indicator: (upper: Double, middle: Double, lower: Double), index: Int)] {
        // Show last 100 bars for better visibility
        let data = Array(chartData.suffix(100))

        // Only keep bars with valid Bollinger Bands (filter out completely, don't just zero them)
        return data.filter { item in
            // Keep only if all three bands are valid (non-zero and within reasonable range)
            guard item.indicator.upper > 0,
                  item.indicator.middle > 0,
                  item.indicator.lower > 0 else {
                return false
            }

            // Check if bands are within reasonable range of price (50% deviation max)
            let reasonableRange = item.bar.close * 0.5

            return abs(item.indicator.upper - item.bar.close) <= reasonableRange &&
                   abs(item.indicator.lower - item.bar.close) <= reasonableRange
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Price & Bollinger Bands")
                .font(Constants.Typography.headline)
                .foregroundColor(Constants.Colors.primaryText)
                .padding(.horizontal, Constants.Spacing.md)

            Chart {
                // Bollinger Band Lines - only drawing valid consecutive values
                ForEach(Array(visibleData.enumerated()), id: \.offset) { offset, data in
                    LineMark(
                        x: .value("Index", offset),
                        y: .value("Upper BB", data.indicator.upper)
                    )
                    .foregroundStyle(Color.gray.opacity(0.6))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                }

                ForEach(Array(visibleData.enumerated()), id: \.offset) { offset, data in
                    LineMark(
                        x: .value("Index", offset),
                        y: .value("Middle BB", data.indicator.middle)
                    )
                    .foregroundStyle(Color.gray.opacity(0.6))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                }

                ForEach(Array(visibleData.enumerated()), id: \.offset) { offset, data in
                    LineMark(
                        x: .value("Index", offset),
                        y: .value("Lower BB", data.indicator.lower)
                    )
                    .foregroundStyle(Color.gray.opacity(0.6))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                }

                // Candlesticks
                ForEach(Array(visibleData.enumerated()), id: \.offset) { offset, data in
                    // Candlestick wick (high-low line)
                    RectangleMark(
                        x: .value("Index", offset),
                        yStart: .value("Low", data.bar.low),
                        yEnd: .value("High", data.bar.high),
                        width: 1
                    )
                    .foregroundStyle(data.bar.isBullish ? Constants.Colors.buyGreen.opacity(0.6) : Constants.Colors.sellRed.opacity(0.6))

                    // Candlestick body (open-close box)
                    RectangleMark(
                        x: .value("Index", offset),
                        yStart: .value("Open", min(data.bar.open, data.bar.close)),
                        yEnd: .value("Close", max(data.bar.open, data.bar.close)),
                        width: 4
                    )
                    .foregroundStyle(data.bar.isBullish ? Constants.Colors.buyGreen : Constants.Colors.sellRed)
                }
            }
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .automatic(desiredCount: 5)) { value in
                    if let index = value.as(Int.self), index < visibleData.count {
                        let timestamp = visibleData[index].bar.timestamp
                        AxisValueLabel {
                            Text(timestamp.formatAsTime())
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing) { value in
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
            .frame(height: 200)
            .padding(.horizontal, Constants.Spacing.sm)

            // Legend
            HStack {
                Spacer()
                Text("30-min bars")
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
