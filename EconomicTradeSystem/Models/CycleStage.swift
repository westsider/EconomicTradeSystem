//
//  CycleStage.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import Foundation
import SwiftUI

enum CycleStage: String, Codable {
    case expansion = "Expansion"
    case peak = "Peak"
    case contraction = "Contraction"
    case recovery = "Recovery"

    var color: Color {
        switch self {
        case .expansion: return Color(hex: "#34C759") // Green
        case .peak: return Color(hex: "#FF9500")      // Orange
        case .contraction: return Color(hex: "#FF3B30") // Red
        case .recovery: return Color(hex: "#0071E3")  // Blue
        }
    }

    var icon: String {
        switch self {
        case .expansion: return "arrow.up.right.circle.fill"
        case .peak: return "arrow.up.circle.fill"
        case .contraction: return "arrow.down.right.circle.fill"
        case .recovery: return "arrow.up.left.circle.fill"
        }
    }

    var description: String {
        switch self {
        case .expansion:
            return "The economy is experiencing healthy growth with positive GDP, falling unemployment, and moderate inflation. This is typically the longest phase of the economic cycle and the best time for equity investments."
        case .peak:
            return "Economic growth is slowing, inflation is rising, and the yield curve may be inverting. The Federal Reserve often raises interest rates to cool down the economy. This phase signals caution for investors."
        case .contraction:
            return "GDP growth has turned negative, unemployment is rising, and economic activity is declining. This is a recession phase where defensive investments and cash preservation are priorities."
        case .recovery:
            return "The economy has bottomed and is beginning to grow again. Unemployment remains high but is starting to fall. Interest rates are typically low, making it an opportune time for early equity investments."
        }
    }

    var tradingStrategy: String {
        switch self {
        case .expansion:
            return "Favor bullish signals. Enter long positions when technical indicators confirm oversold conditions. The risk/reward is favorable for swing trading strategies."
        case .peak:
            return "Exercise caution. Reduce position sizes and tighten stop losses. Consider taking profits on existing positions as the cycle may be turning."
        case .contraction:
            return "Avoid new long positions or trade defensively. Focus on capital preservation. Short-term oversold bounces may occur but are risky in a declining economic environment."
        case .recovery:
            return "Begin accumulating positions on pullbacks. Early recovery offers excellent risk/reward as the economy stabilizes. Look for confirmation from both technical and economic indicators."
        }
    }

    var iconName: String {
        switch self {
        case .expansion: return "arrow.up.right.circle.fill"
        case .peak: return "exclamationmark.triangle.fill"
        case .contraction: return "arrow.down.circle.fill"
        case .recovery: return "arrow.up.circle.fill"
        }
    }

    var gradient: Gradient {
        switch self {
        case .expansion:
            return Gradient(colors: [
                Color(red: 0.38, green: 0.93, blue: 0.78),
                Color(red: 0.10, green: 0.80, blue: 0.47)
            ])
        case .peak:
            return Gradient(colors: [
                Color(red: 1.0, green: 0.65, blue: 0.0),
                Color(red: 1.0, green: 0.45, blue: 0.0)
            ])
        case .contraction:
            return Gradient(colors: [
                Color(red: 1.0, green: 0.30, blue: 0.30),
                Color(red: 0.90, green: 0.10, blue: 0.10)
            ])
        case .recovery:
            return Gradient(colors: [
                Color(red: 0.0, green: 0.60, blue: 0.95),
                Color(red: 0.0, green: 0.45, blue: 0.85)
            ])
        }
    }
}
