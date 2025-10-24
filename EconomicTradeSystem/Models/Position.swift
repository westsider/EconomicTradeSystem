//
//  Position.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import Foundation

enum PositionStatus: String, Codable {
    case open = "Open"
    case closed = "Closed"
}

struct Position: Identifiable, Codable {
    let id: UUID
    let symbol: String
    let entryDate: Date
    let entryPrice: Double
    let entrySignal: Signal
    var exitDate: Date?
    var exitPrice: Double?
    var exitSignal: Signal?
    var shares: Double
    var stopLoss: Double
    var status: PositionStatus

    init(
        id: UUID = UUID(),
        symbol: String,
        entryDate: Date,
        entryPrice: Double,
        entrySignal: Signal,
        shares: Double,
        stopLoss: Double,
        exitDate: Date? = nil,
        exitPrice: Double? = nil,
        exitSignal: Signal? = nil,
        status: PositionStatus = .open
    ) {
        self.id = id
        self.symbol = symbol
        self.entryDate = entryDate
        self.entryPrice = entryPrice
        self.entrySignal = entrySignal
        self.shares = shares
        self.stopLoss = stopLoss
        self.exitDate = exitDate
        self.exitPrice = exitPrice
        self.exitSignal = exitSignal
        self.status = status
    }

    // Helper computed properties
    var entryValue: Double {
        entryPrice * shares
    }

    var currentValue: Double? {
        guard let exitPrice = exitPrice else { return nil }
        return exitPrice * shares
    }

    var profitLoss: Double? {
        guard let exitPrice = exitPrice else { return nil }
        return (exitPrice - entryPrice) * shares
    }

    var profitLossPercent: Double? {
        guard let exitPrice = exitPrice else { return nil }
        return ((exitPrice - entryPrice) / entryPrice) * 100
    }

    var holdingPeriod: TimeInterval? {
        guard let exitDate = exitDate else { return nil }
        return exitDate.timeIntervalSince(entryDate)
    }

    var formattedProfitLoss: String {
        guard let pl = profitLoss else { return "N/A" }
        let sign = pl >= 0 ? "+" : ""
        return "\(sign)$\(String(format: "%.2f", pl))"
    }

    var formattedProfitLossPercent: String {
        guard let plPercent = profitLossPercent else { return "N/A" }
        let sign = plPercent >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", plPercent))%"
    }
}
