//
//  TechnicalIndicators.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import Foundation

struct TechnicalIndicators: Codable {
    // Bollinger Bands
    let bollingerUpper: Double
    let bollingerMiddle: Double
    let bollingerLower: Double

    // Keltner Channel (optional for squeeze detection)
    let keltnerUpper: Double?
    let keltnerLower: Double?

    // RSI
    let rsi: Double

    // MACD (optional for future enhancements)
    let macd: Double?
    let macdSignal: Double?
    let macdHistogram: Double?

    // ATR (for volatility and position sizing)
    let atr: Double?

    init(
        bollingerUpper: Double,
        bollingerMiddle: Double,
        bollingerLower: Double,
        rsi: Double,
        keltnerUpper: Double? = nil,
        keltnerLower: Double? = nil,
        macd: Double? = nil,
        macdSignal: Double? = nil,
        macdHistogram: Double? = nil,
        atr: Double? = nil
    ) {
        self.bollingerUpper = bollingerUpper
        self.bollingerMiddle = bollingerMiddle
        self.bollingerLower = bollingerLower
        self.rsi = rsi
        self.keltnerUpper = keltnerUpper
        self.keltnerLower = keltnerLower
        self.macd = macd
        self.macdSignal = macdSignal
        self.macdHistogram = macdHistogram
        self.atr = atr
    }

    // Helper computed properties
    var bollingerBandwidth: Double {
        (bollingerUpper - bollingerLower) / bollingerMiddle
    }

    var isRSIOversold: Bool {
        rsi < 30
    }

    var isRSIOverbought: Bool {
        rsi > 70
    }

    var isSqueeze: Bool {
        guard let keltnerUpper = keltnerUpper, let keltnerLower = keltnerLower else {
            return false
        }
        return bollingerUpper < keltnerUpper && bollingerLower > keltnerLower
    }
}
