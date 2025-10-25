//
//  EconomicCycleClassifier.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/25/25.
//

import Foundation

class EconomicCycleClassifier {
    private var economicData: [EconomicData] = []
    private var classifications: [(date: Date, stage: CycleStage)] = []

    // MARK: - Classify Economic Data
    func classify(data: [EconomicData]) -> [(date: Date, stage: CycleStage)] {
        self.economicData = data

        // Calculate smoothed averages and trends
        let smoothedData = calculateSmoothingAndTrends(data: data)

        // Classify each period
        var results: [(date: Date, stage: CycleStage)] = []
        for dataPoint in smoothedData {
            let stage = classifySinglePeriod(data: dataPoint)
            results.append((date: dataPoint.date, stage: stage))
        }

        self.classifications = results
        return results
    }

    // MARK: - Get Current Stage
    func getCurrentStage() -> CycleStage? {
        return classifications.last?.stage
    }

    // MARK: - Get Cycle Changes
    func getCycleChanges() -> [(date: Date, fromStage: CycleStage, toStage: CycleStage)] {
        var changes: [(date: Date, fromStage: CycleStage, toStage: CycleStage)] = []

        for i in 1..<classifications.count {
            let previous = classifications[i-1]
            let current = classifications[i]

            if previous.stage != current.stage {
                changes.append((date: current.date, fromStage: previous.stage, toStage: current.stage))
            }
        }

        return changes
    }

    // MARK: - Calculate Smoothing and Trends
    private func calculateSmoothingAndTrends(data: [EconomicData]) -> [EconomicData] {
        var smoothedData: [EconomicData] = []
        let smoothingPeriod = Constants.EconomicCycle.smoothingPeriod

        for i in 0..<data.count {
            var smoothedPoint = data[i]

            // Calculate 90-day moving average for GDP
            if i >= smoothingPeriod {
                let gdpValues = data[(i-smoothingPeriod)...i].compactMap { $0.gdpGrowth }
                if !gdpValues.isEmpty {
                    smoothedPoint.gdpGrowth = gdpValues.reduce(0, +) / Double(gdpValues.count)
                }
            }

            // Calculate GDP trend (90-day)
            if i >= smoothingPeriod {
                let gdpValues = data[(i-smoothingPeriod)...i].compactMap { $0.gdpGrowth }
                if gdpValues.count > 1 {
                    let startGDP = gdpValues.first ?? 0
                    let endGDP = gdpValues.last ?? 0
                    smoothedPoint.gdpTrend = endGDP - startGDP
                }
            }

            // Calculate unemployment trend (90-day)
            if i >= smoothingPeriod {
                let unempValues = data[(i-smoothingPeriod)...i].compactMap { $0.unemployment }
                if unempValues.count > 1 {
                    let startUnemp = unempValues.first ?? 0
                    let endUnemp = unempValues.last ?? 0
                    smoothedPoint.unemploymentTrend = endUnemp - startUnemp
                }
            }

            smoothedData.append(smoothedPoint)
        }

        return smoothedData
    }

    // MARK: - Classify Single Period
    /// Classification rules from Python web app (cycle_classifier.py lines 93-142)
    private func classifySinglePeriod(data: EconomicData) -> CycleStage {
        // Extract values with defaults
        let gdp = data.gdpGrowth ?? 0
        let gdpTrend = data.gdpTrend ?? 0
        let unemployment = data.unemployment ?? 0
        let unemploymentTrend = data.unemploymentTrend ?? 0
        let inflation = data.inflation ?? 0
        let yieldCurve = data.yieldCurve ?? 0

        // CONTRACTION: GDP < 0 OR unemployment rising significantly
        if gdp < Constants.EconomicCycle.contractionGDPThreshold ||
           unemploymentTrend > Constants.EconomicCycle.contractionUnemploymentTrend {
            return .contraction
        }

        // PEAK: GDP growth slowing AND high inflation OR inverted yield curve
        if (gdpTrend < Constants.EconomicCycle.peakGDPTrend &&
            inflation > Constants.EconomicCycle.peakInflation) ||
           yieldCurve < Constants.EconomicCycle.peakYieldCurve {
            return .peak
        }

        // RECOVERY: Positive but low GDP growth AND high unemployment but falling
        if gdp >= Constants.EconomicCycle.recoveryGDPMin &&
           gdp < Constants.EconomicCycle.recoveryGDPMax &&
           unemployment > Constants.EconomicCycle.recoveryUnemploymentMin &&
           unemploymentTrend < Constants.EconomicCycle.recoveryUnemploymentTrend {
            return .recovery
        }

        // EXPANSION: Default - positive GDP and stable/falling unemployment
        if gdp >= 0 && unemploymentTrend <= 0 {
            return .expansion
        }

        // Default to hold if no clear classification
        return .expansion
    }
}
