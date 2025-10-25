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

    @State private var scrollPosition: Int = 0
    @State private var visibleBarCount: Int = 100

    private var chartData: [(bar: PriceBar, indicator: (upper: Double, middle: Double, lower: Double), index: Int)] {
        var data: [(bar: PriceBar, indicator: (upper: Double, middle: Double, lower: Double), index: Int)] = []
        for (index, bar) in priceBars.enumerated() {
            if index < indicators.count {
                data.append((bar: bar, indicator: indicators[index], index: index))
            }
        }
        return data
    }

    private var allValidData: [(bar: PriceBar, indicator: (upper: Double, middle: Double, lower: Double), index: Int)] {
        // Filter all data to only include valid Bollinger Bands
        return chartData.filter { item in
            guard item.indicator.upper > 0,
                  item.indicator.middle > 0,
                  item.indicator.lower > 0 else {
                return false
            }

            let reasonableRange = item.bar.close * 0.5
            return abs(item.indicator.upper - item.bar.close) <= reasonableRange &&
                   abs(item.indicator.lower - item.bar.close) <= reasonableRange
        }
    }

    private var visibleData: [(bar: PriceBar, indicator: (upper: Double, middle: Double, lower: Double), index: Int)] {
        let total = allValidData.count
        let endIndex = total
        let startIndex = max(0, endIndex - visibleBarCount)

        return Array(allValidData[startIndex..<endIndex])
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Price & Bollinger Bands")
                .font(Constants.Typography.headline)
                .foregroundColor(Constants.Colors.primaryText)
                .padding(.horizontal, Constants.Spacing.md)

            Chart {
                // Bollinger Bands - draw as point marks instead of lines to avoid artifacts
                ForEach(Array(visibleData.enumerated()), id: \.offset) { offset, data in
                    PointMark(
                        x: .value("Index", offset),
                        y: .value("Upper BB", data.indicator.upper)
                    )
                    .symbolSize(2)
                    .foregroundStyle(Color.gray.opacity(0.4))
                }

                ForEach(Array(visibleData.enumerated()), id: \.offset) { offset, data in
                    PointMark(
                        x: .value("Index", offset),
                        y: .value("Middle BB", data.indicator.middle)
                    )
                    .symbolSize(2)
                    .foregroundStyle(Color.gray.opacity(0.4))
                }

                ForEach(Array(visibleData.enumerated()), id: \.offset) { offset, data in
                    PointMark(
                        x: .value("Index", offset),
                        y: .value("Lower BB", data.indicator.lower)
                    )
                    .symbolSize(2)
                    .foregroundStyle(Color.gray.opacity(0.4))
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
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        // Zoom in/out by adjusting visible bar count
                        let newCount = Int(Double(100) / value)
                        visibleBarCount = max(20, min(allValidData.count, newCount))
                    }
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Allow horizontal scrolling (for future enhancement)
                        // This could be implemented to scroll through historical data
                    }
            )

            // Zoom controls
            HStack(spacing: Constants.Spacing.sm) {
                Button(action: {
                    withAnimation {
                        visibleBarCount = max(20, visibleBarCount - 20)
                    }
                }) {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.caption)
                        .foregroundColor(Constants.Colors.accent)
                        .padding(8)
                        .background(Circle().fill(Constants.Colors.cardBackground))
                        .overlay(Circle().stroke(Constants.Colors.accent.opacity(0.3), lineWidth: 1))
                }

                Button(action: {
                    withAnimation {
                        visibleBarCount = min(allValidData.count, visibleBarCount + 20)
                    }
                }) {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.caption)
                        .foregroundColor(Constants.Colors.accent)
                        .padding(8)
                        .background(Circle().fill(Constants.Colors.cardBackground))
                        .overlay(Circle().stroke(Constants.Colors.accent.opacity(0.3), lineWidth: 1))
                }

                Spacer()

                Text("\(visibleBarCount) bars")
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.secondaryText)
            }
            .padding(.horizontal, Constants.Spacing.md)

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
