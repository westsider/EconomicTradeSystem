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
            return "Economy is growing. Bullish signals favored."
        case .peak:
            return "Economy at peak. Caution advised."
        case .contraction:
            return "Economy is contracting. Bearish signals favored."
        case .recovery:
            return "Economy is recovering. Early bullish signals."
        }
    }
}
