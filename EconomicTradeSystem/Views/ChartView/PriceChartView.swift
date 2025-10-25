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

    @ObservedObject var indicatorSettings = IndicatorSettings.shared
    @State private var scrollPosition: Int = 0
    @State private var baseScrollPosition: Int = 0
    @State private var visibleBarCount: Int = 100

    private var rsiValues: [Double] {
        IndicatorCalculator.calculateRSI(bars: priceBars)
    }

    private var chartData: [(bar: PriceBar, indicator: (upper: Double, middle: Double, lower: Double), index: Int)] {
        var data: [(bar: PriceBar, indicator: (upper: Double, middle: Double, lower: Double), index: Int)] = []
        for (index, bar) in priceBars.enumerated() {
            if index < indicators.count {
                data.append((bar: bar, indicator: indicators[index], index: index))
            }
        }
        return data
    }

    // Calculate buy/sell signals for each bar
    private func getSignalType(for index: Int, in data: [(bar: PriceBar, indicator: (upper: Double, middle: Double, lower: Double), index: Int)]) -> SignalType? {
        guard index < data.count,
              index < rsiValues.count,
              rsiValues[index] > 0 else {
            return nil
        }

        let item = data[index]
        let rsi = rsiValues[index]

        // Buy signal: Price touches/crosses Lower BB AND RSI < oversold threshold
        let priceBelowOrAtLower = item.bar.close <= item.indicator.lower
        let rsiOversold = rsi < indicatorSettings.rsiOversold

        if priceBelowOrAtLower && rsiOversold {
            print("🟢 BUY Signal at index \(index): close=\(item.bar.close), lower BB=\(item.indicator.lower), RSI=\(rsi)")
            return .buy
        }

        // Debug: Check if price touches lower band but RSI isn't low enough
        if priceBelowOrAtLower && !rsiOversold {
            print("⚠️ Near BUY at index \(index): close=\(item.bar.close), lower BB=\(item.indicator.lower), RSI=\(rsi) (needs < \(Int(indicatorSettings.rsiOversold)))")
        }

        // Sell signal: Price touches/crosses Upper BB AND RSI > overbought threshold
        let priceAboveOrAtUpper = item.bar.close >= item.indicator.upper
        let rsiOverbought = rsi > indicatorSettings.rsiOverbought

        if priceAboveOrAtUpper && rsiOverbought {
            print("🔴 SELL Signal at index \(index): close=\(item.bar.close), upper BB=\(item.indicator.upper), RSI=\(rsi)")
            return .sell
        }

        return nil
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
        // Use scrollPosition to determine which bars to show
        let endIndex = min(total, total - scrollPosition)
        let startIndex = max(0, endIndex - visibleBarCount)

        return Array(allValidData[startIndex..<endIndex])
    }

    // Debug: Count signals in visible data
    private var signalCounts: (buy: Int, sell: Int) {
        var buyCount = 0
        var sellCount = 0

        for (_, data) in visibleData.enumerated() {
            let globalIndex = data.index
            if let signalType = getSignalType(for: globalIndex, in: allValidData) {
                if signalType == .buy {
                    buyCount += 1
                } else {
                    sellCount += 1
                }
            }
        }

        print("📊 Signal Summary: \(buyCount) BUY signals, \(sellCount) SELL signals in visible data")
        return (buyCount, sellCount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Price & Bollinger Bands")
                .font(Constants.Typography.headline)
                .foregroundColor(Constants.Colors.primaryText)
                .padding(.horizontal, Constants.Spacing.md)
                .onAppear {
                    // Trigger signal count debug
                    let _ = signalCounts
                }

            Chart {
                // Bollinger Bands - draw as point marks instead of lines to avoid artifacts
                ForEach(Array(visibleData.enumerated()), id: \.offset) { offset, data in
                    PointMark(
                        x: .value("Index", offset),
                        y: .value("Upper BB", data.indicator.upper)
                    )
                    .symbolSize(6)
                    .foregroundStyle(Color.gray.opacity(0.7))
                }

                ForEach(Array(visibleData.enumerated()), id: \.offset) { offset, data in
                    PointMark(
                        x: .value("Index", offset),
                        y: .value("Middle BB", data.indicator.middle)
                    )
                    .symbolSize(6)
                    .foregroundStyle(Color.gray.opacity(0.7))
                }

                ForEach(Array(visibleData.enumerated()), id: \.offset) { offset, data in
                    PointMark(
                        x: .value("Index", offset),
                        y: .value("Lower BB", data.indicator.lower)
                    )
                    .symbolSize(6)
                    .foregroundStyle(Color.gray.opacity(0.7))
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

                // Signal markers (Buy/Sell)
                ForEach(Array(visibleData.enumerated()), id: \.offset) { offset, data in
                    let globalIndex = data.index
                    if let signalType = getSignalType(for: globalIndex, in: allValidData) {
                        // Position marker below low for buy, above high for sell
                        let yPosition = signalType == .buy ? data.bar.low * 0.998 : data.bar.high * 1.002

                        PointMark(
                            x: .value("Index", offset),
                            y: .value("Signal", yPosition)
                        )
                        .symbol {
                            if signalType == .buy {
                                // Green up arrow for buy
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Constants.Colors.buyGreen)
                            } else {
                                // Red down arrow for sell
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Constants.Colors.sellRed)
                            }
                        }
                    }
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
            .simultaneousGesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        // Pan left/right by adjusting scroll position in real-time
                        let dragAmount = Int(value.translation.width / 3)
                        let maxScroll = max(0, allValidData.count - visibleBarCount)
                        scrollPosition = max(0, min(maxScroll, baseScrollPosition - dragAmount))
                    }
                    .onEnded { _ in
                        // Save the final position
                        baseScrollPosition = scrollPosition
                    }
            )
            .simultaneousGesture(
                MagnificationGesture()
                    .onChanged { value in
                        // Zoom in/out by adjusting visible bar count
                        let newCount = Int(Double(100) / value)
                        visibleBarCount = max(20, min(allValidData.count, newCount))
                    }
            )

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
