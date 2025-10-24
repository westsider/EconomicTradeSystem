//
//  Trade.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import Foundation

struct Trade: Identifiable, Codable {
    let id: UUID
    let positionId: UUID
    let symbol: String
    let entryDate: Date
    let entryPrice: Double
    let exitDate: Date
    let exitPrice: Double
    let shares: Double
    let profitLoss: Double
    let profitLossPercent: Double
    let entrySignal: Signal
    let exitSignal: Signal

    init(
        id: UUID = UUID(),
        positionId: UUID,
        symbol: String,
        entryDate: Date,
        entryPrice: Double,
        exitDate: Date,
        exitPrice: Double,
        shares: Double,
        entrySignal: Signal,
        exitSignal: Signal
    ) {
        self.id = id
        self.positionId = positionId
        self.symbol = symbol
        self.entryDate = entryDate
        self.entryPrice = entryPrice
        self.exitDate = exitDate
        self.exitPrice = exitPrice
        self.shares = shares
        self.entrySignal = entrySignal
        self.exitSignal = exitSignal

        // Calculate P/L
        self.profitLoss = (exitPrice - entryPrice) * shares
        self.profitLossPercent = ((exitPrice - entryPrice) / entryPrice) * 100
    }

    // Helper computed properties
    var isWinner: Bool {
        profitLoss > 0
    }

    var holdingPeriod: TimeInterval {
        exitDate.timeIntervalSince(entryDate)
    }

    var formattedHoldingPeriod: String {
        let hours = Int(holdingPeriod / 3600)
        let days = hours / 24
        let remainingHours = hours % 24

        if days > 0 {
            return "\(days)d \(remainingHours)h"
        } else {
            return "\(hours)h"
        }
    }

    var formattedProfitLoss: String {
        let sign = profitLoss >= 0 ? "+" : ""
        return "\(sign)$\(String(format: "%.2f", profitLoss))"
    }

    var formattedProfitLossPercent: String {
        let sign = profitLossPercent >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", profitLossPercent))%"
    }
}
