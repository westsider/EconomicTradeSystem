//
//  Constants.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import Foundation
import SwiftUI

struct Constants {
    // MARK: - API Configuration
    struct API {
        static let polygonBaseURL = "https://api.polygon.io"
        static let fredBaseURL = "https://api.stlouisfed.org/fred"

        // FRED API Series IDs for Economic Indicators
        struct FREDSeries {
            static let gdpGrowth = "A191RL1Q225SBEA"      // Real GDP Growth Rate
            static let unemployment = "UNRATE"             // Unemployment Rate
            static let cpi = "CPIAUCSL"                    // Consumer Price Index
            static let fedFunds = "FEDFUNDS"               // Federal Funds Rate
            static let treasury10Y = "GS10"                // 10-Year Treasury Rate
            static let treasury2Y = "GS2"                  // 2-Year Treasury Rate
            static let payrolls = "PAYEMS"                 // Total Nonfarm Payrolls
            static let consumerSentiment = "UMCSENT"       // Consumer Sentiment Index
        }
    }

    // MARK: - Trading Configuration
    struct Trading {
        static let defaultSymbol = "GPIX"
        static let availableSymbols = ["GPIX", "SPY", "QQQ", "TSLA", "AAPL"]
        static let defaultCapital: Double = 30000
        static let defaultStopLossPercent: Double = 0.02 // 2%
    }

    // MARK: - Technical Indicators
    struct Indicators {
        static let bollingerPeriod = 20
        static let bollingerStdDev = 2.0
        static let rsiPeriod = 14
        static let rsiOversold = 30.0
        static let rsiOverbought = 70.0
        static let keltnerPeriod = 20
        static let keltnerATRMultiplier = 2.0
    }

    // MARK: - Economic Cycle Configuration
    struct EconomicCycle {
        static let smoothingPeriod = 90  // Days for moving average smoothing
        static let yieldCurveSmoothingPeriod = 30  // Days for yield curve smoothing

        // Classification thresholds (from Python web app)
        static let contractionGDPThreshold = 0.0
        static let contractionUnemploymentTrend = 0.3
        static let peakGDPTrend = -0.5
        static let peakInflation = 3.5
        static let peakYieldCurve = -0.2
        static let recoveryGDPMin = 0.0
        static let recoveryGDPMax = 2.0
        static let recoveryUnemploymentMin = 6.0
        static let recoveryUnemploymentTrend = -0.1
    }

    // MARK: - Update Intervals
    struct Updates {
        static let barInterval: TimeInterval = 30 * 60 // 30 minutes
        static let backgroundFetchInterval: TimeInterval = 30 * 60 // 30 minutes
        static let minimumRefreshInterval: TimeInterval = 5 * 60 // 5 minutes
    }

    // MARK: - UI Colors (Apple Style)
    struct Colors {
        static let primaryText = Color(hex: "#1d1d1f")
        static let secondaryText = Color(hex: "#6e6e73")
        static let background = Color(hex: "#f5f5f7")
        static let cardBackground = Color.white
        static let accent = Color(hex: "#0071E3")

        // Signal colors
        static let buyGreen = Color(hex: "#34C759")
        static let sellRed = Color(hex: "#FF3B30")
        static let holdGray = Color(hex: "#8E8E93")

        // Cycle colors
        static let expansionGreen = Color(hex: "#34C759")
        static let peakOrange = Color(hex: "#FF9500")
        static let contractionRed = Color(hex: "#FF3B30")
        static let recoveryBlue = Color(hex: "#0071E3")
    }

    // MARK: - Typography
    struct Typography {
        static let largeTitle: Font = .system(size: 34, weight: .bold, design: .default)
        static let title: Font = .system(size: 28, weight: .bold, design: .default)
        static let title2: Font = .system(size: 22, weight: .bold, design: .default)
        static let title3: Font = .system(size: 20, weight: .semibold, design: .default)
        static let headline: Font = .system(size: 17, weight: .semibold, design: .default)
        static let body: Font = .system(size: 17, weight: .regular, design: .default)
        static let callout: Font = .system(size: 16, weight: .regular, design: .default)
        static let subheadline: Font = .system(size: 15, weight: .regular, design: .default)
        static let footnote: Font = .system(size: 13, weight: .regular, design: .default)
        static let caption: Font = .system(size: 12, weight: .regular, design: .default)
    }

    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    // MARK: - Border Radius
    struct Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }
}
