//
//  PriceBar.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import Foundation

struct PriceBar: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Int64

    init(id: UUID = UUID(), timestamp: Date, open: Double, high: Double, low: Double, close: Double, volume: Int64) {
        self.id = id
        self.timestamp = timestamp
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
    }

    // Helper computed properties
    var range: Double {
        high - low
    }

    var body: Double {
        abs(close - open)
    }

    var isBullish: Bool {
        close > open
    }
}
