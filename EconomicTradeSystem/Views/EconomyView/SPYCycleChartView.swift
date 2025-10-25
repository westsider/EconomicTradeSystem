//
//  SPYCycleChartView.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/25/25.
//

import SwiftUI
import Charts

struct SPYCycleChartView: View {
    let priceBars: [PriceBar]
    let cycleStages: [(date: Date, stage: CycleStage)]

    @State private var visibleBarCount: Int = 365 // Show 1 year by default

    private var chartData: [(bar: PriceBar, stage: CycleStage?, index: Int)] {
        var data: [(bar: PriceBar, stage: CycleStage?, index: Int)] = []

        for (index, bar) in priceBars.enumerated() {
            // Find the cycle stage for this date
            let stage = cycleStages.last(where: { $0.date <= bar.timestamp })?.stage
            data.append((bar: bar, stage: stage, index: index))
        }

        return data
    }

    private var visibleData: [(bar: PriceBar, stage: CycleStage?, index: Int)] {
        let total = chartData.count
        let endIndex = total
        let startIndex = max(0, endIndex - visibleBarCount)

        return Array(chartData[startIndex..<endIndex])
    }

    // Group consecutive bars with same cycle stage for background zones
    private var cycleZones: [(startIndex: Int, endIndex: Int, stage: CycleStage)] {
        var zones: [(startIndex: Int, endIndex: Int, stage: CycleStage)] = []

        if visibleData.isEmpty { return zones }

        var currentStage = visibleData.first?.stage
        var startIndex = 0

        for (index, data) in visibleData.enumerated() {
            if data.stage != currentStage {
                // Save previous zone
                if let stage = currentStage {
                    zones.append((startIndex: startIndex, endIndex: index - 1, stage: stage))
                }
                // Start new zone
                currentStage = data.stage
                startIndex = index
            }
        }

        // Add final zone
        if let stage = currentStage {
            zones.append((startIndex: startIndex, endIndex: visibleData.count - 1, stage: stage))
        }

        return zones
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("S&P 500 with Economic Cycles")
                .font(Constants.Typography.headline)
                .foregroundColor(Constants.Colors.primaryText)
                .padding(.horizontal, Constants.Spacing.md)

            Chart {
                // Background zones for economic cycles
                ForEach(cycleZones, id: \.startIndex) { zone in
                    RectangleMark(
                        xStart: .value("Start", zone.startIndex),
                        xEnd: .value("End", zone.endIndex + 1),
                        yStart: .value("Min", visibleData.map { $0.bar.low }.min() ?? 0),
                        yEnd: .value("Max", visibleData.map { $0.bar.high }.max() ?? 500)
                    )
                    .foregroundStyle(zone.stage.color.opacity(0.15))
                }

                // Price line
                ForEach(Array(visibleData.enumerated()), id: \.offset) { offset, data in
                    LineMark(
                        x: .value("Index", offset),
                        y: .value("Close", data.bar.close)
                    )
                    .foregroundStyle(Constants.Colors.accent)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
            }
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .automatic(desiredCount: 6)) { value in
                    if let index = value.as(Int.self), index < visibleData.count {
                        let timestamp = visibleData[index].bar.timestamp
                        AxisValueLabel {
                            Text(timestamp.formatAsMonthYear())
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
            .frame(height: 250)
            .padding(.horizontal, Constants.Spacing.sm)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        // Zoom in/out by adjusting visible bar count
                        let newCount = Int(Double(365) / value)
                        visibleBarCount = max(90, min(chartData.count, newCount))
                    }
            )

            // Legend
            HStack(spacing: Constants.Spacing.md) {
                ForEach([CycleStage.expansion, .peak, .contraction, .recovery], id: \.self) { stage in
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(stage.color)
                            .frame(width: 12, height: 12)
                            .cornerRadius(2)
                        Text(stage.rawValue)
                            .font(Constants.Typography.caption)
                            .foregroundColor(Constants.Colors.secondaryText)
                    }
                }
            }
            .padding(.horizontal, Constants.Spacing.md)

            Text("Pinch to zoom • Showing last \(visibleBarCount) days")
                .font(Constants.Typography.caption)
                .foregroundColor(Constants.Colors.secondaryText)
                .padding(.horizontal, Constants.Spacing.md)
        }
        .padding(.vertical, Constants.Spacing.md)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.Radius.large)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// Date formatting extension for month/year
extension Date {
    func formatAsMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yy"
        return formatter.string(from: self)
    }
}

#Preview {
    let bars = (0..<365).map { i in
        PriceBar(
            timestamp: Date().addingTimeInterval(TimeInterval(i * 86400)),
            open: 400.0 + Double.random(in: -10...10),
            high: 410.0 + Double.random(in: -10...10),
            low: 390.0 + Double.random(in: -10...10),
            close: 400.0 + Double.random(in: -10...10),
            volume: 1000000
        )
    }

    let stages: [(date: Date, stage: CycleStage)] = [
        (Date().addingTimeInterval(-365 * 86400), .expansion),
        (Date().addingTimeInterval(-200 * 86400), .peak),
        (Date().addingTimeInterval(-100 * 86400), .contraction),
        (Date().addingTimeInterval(-30 * 86400), .recovery)
    ]

    SPYCycleChartView(priceBars: bars, cycleStages: stages)
        .padding()
        .background(Constants.Colors.background)
}
