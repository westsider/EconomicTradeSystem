//
//  Signal.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import Foundation
import SwiftUI

enum SignalType: String, Codable {
    case buy = "BUY"
    case sell = "SELL"
    case hold = "HOLD"

    var color: Color {
        switch self {
        case .buy: return Color(hex: "#34C759") // Green
        case .sell: return Color(hex: "#FF3B30") // Red
        case .hold: return Color(hex: "#8E8E93") // Gray
        }
    }

    var icon: String {
        switch self {
        case .buy: return "arrow.up.circle.fill"
        case .sell: return "arrow.down.circle.fill"
        case .hold: return "pause.circle.fill"
        }
    }
}

struct Signal: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let symbol: String
    let type: SignalType
    let price: Double
    let indicators: TechnicalIndicators
    let cycleStage: CycleStage?
    let reason: String

    init(
        id: UUID = UUID(),
        timestamp: Date,
        symbol: String,
        type: SignalType,
        price: Double,
        indicators: TechnicalIndicators,
        cycleStage: CycleStage? = nil,
        reason: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.symbol = symbol
        self.type = type
        self.price = price
        self.indicators = indicators
        self.cycleStage = cycleStage
        self.reason = reason
    }

    // Helper computed properties
    var formattedPrice: String {
        String(format: "$%.2f", price)
    }

    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: timestamp)
    }
}
