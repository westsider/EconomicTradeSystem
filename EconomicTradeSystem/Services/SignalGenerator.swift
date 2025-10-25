//
//  SignalGenerator.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import Foundation

class SignalGenerator {
    // MARK: - Generate Signal from Price Bars
    static func generateSignal(
        bars: [PriceBar],
        symbol: String,
        cycleStage: CycleStage? = nil,
        hasOpenPosition: Bool = false
    ) -> Signal? {
        guard bars.count >= Constants.Indicators.bollingerPeriod else {
            return nil
        }

        let lastIndex = bars.count - 1
        let currentBar = bars[lastIndex]

        guard let indicators = IndicatorCalculator.calculateIndicators(bars: bars, index: lastIndex) else {
            return nil
        }

        // Determine signal type based on indicators and position status
        let signalType: SignalType
        let reason: String

        if hasOpenPosition {
            // Check for exit signals
            if shouldExit(currentBar: currentBar, indicators: indicators) {
                signalType = .sell
                reason = getExitReason(currentBar: currentBar, indicators: indicators)
            } else {
                signalType = .hold
                reason = "Holding position. RSI: \(Int(indicators.rsi))"
            }
        } else {
            // Check for entry signals
            if shouldEnter(currentBar: currentBar, indicators: indicators, cycleStage: cycleStage) {
                signalType = .buy
                reason = getEntryReason(currentBar: currentBar, indicators: indicators, cycleStage: cycleStage)
            } else {
                signalType = .hold
                reason = "No entry signal. RSI: \(Int(indicators.rsi))"
            }
        }

        return Signal(
            timestamp: currentBar.timestamp,
            symbol: symbol,
            type: signalType,
            price: currentBar.close,
            indicators: indicators,
            cycleStage: cycleStage,
            reason: reason
        )
    }

    // MARK: - Entry Logic
    private static func shouldEnter(
        currentBar: PriceBar,
        indicators: TechnicalIndicators,
        cycleStage: CycleStage?
    ) -> Bool {
        // Entry condition: Price < Lower BB AND RSI < oversold threshold
        let priceBelowLowerBB = currentBar.close < indicators.bollingerLower
        let rsiOversold = indicators.rsi < IndicatorSettings.shared.rsiOversold

        // Basic entry signal
        let basicSignal = priceBelowLowerBB && rsiOversold

        // Optional: Only trade during expansion (if cycle stage is available)
        if let cycle = cycleStage {
            return basicSignal && cycle == .expansion
        }

        return basicSignal
    }

    // MARK: - Exit Logic
    private static func shouldExit(
        currentBar: PriceBar,
        indicators: TechnicalIndicators
    ) -> Bool {
        // Exit condition: Price > Upper BB OR RSI > overbought threshold
        let priceAboveUpperBB = currentBar.close > indicators.bollingerUpper
        let rsiOverbought = indicators.rsi > IndicatorSettings.shared.rsiOverbought

        return priceAboveUpperBB || rsiOverbought
    }

    // MARK: - Get Entry Reason
    private static func getEntryReason(
        currentBar: PriceBar,
        indicators: TechnicalIndicators,
        cycleStage: CycleStage?
    ) -> String {
        var reasons: [String] = []

        if currentBar.close < indicators.bollingerLower {
            let percentBelow = ((indicators.bollingerLower - currentBar.close) / indicators.bollingerLower) * 100
            reasons.append("Price \(String(format: "%.1f%%", percentBelow)) below lower BB")
        }

        if indicators.rsi < IndicatorSettings.shared.rsiOversold {
            reasons.append("RSI oversold at \(Int(indicators.rsi))")
        }

        if let cycle = cycleStage, cycle == .expansion {
            reasons.append("Economy in expansion")
        }

        if indicators.isSqueeze {
            reasons.append("BB squeeze detected")
        }

        return reasons.joined(separator: " • ")
    }

    // MARK: - Get Exit Reason
    private static func getExitReason(
        currentBar: PriceBar,
        indicators: TechnicalIndicators
    ) -> String {
        var reasons: [String] = []

        if currentBar.close > indicators.bollingerUpper {
            let percentAbove = ((currentBar.close - indicators.bollingerUpper) / indicators.bollingerUpper) * 100
            reasons.append("Price \(String(format: "%.1f%%", percentAbove)) above upper BB")
        }

        if indicators.rsi > IndicatorSettings.shared.rsiOverbought {
            reasons.append("RSI overbought at \(Int(indicators.rsi))")
        }

        return reasons.joined(separator: " • ")
    }

    // MARK: - Check Stop Loss
    static func shouldStopOut(
        currentPrice: Double,
        position: Position
    ) -> Bool {
        return currentPrice <= position.stopLoss
    }

    // MARK: - Calculate Position Size
    static func calculatePositionSize(
        capital: Double,
        price: Double,
        stopLossPercent: Double = Constants.Trading.defaultStopLossPercent
    ) -> (shares: Double, stopLoss: Double) {
        // Use 100% of capital for simplicity (can adjust for risk management)
        let shares = capital / price
        let stopLoss = price * (1 - stopLossPercent)

        return (shares: shares, stopLoss: stopLoss)
    }

    // MARK: - Backtest Helper
    static func backtestSignals(
        bars: [PriceBar],
        symbol: String,
        initialCapital: Double = Constants.Trading.defaultCapital
    ) -> [Trade] {
        var trades: [Trade] = []
        var currentPosition: Position?
        var capital = initialCapital

        for i in Constants.Indicators.bollingerPeriod..<bars.count {
            let currentBars = Array(bars[0...i])
            let hasPosition = currentPosition != nil

            guard let signal = generateSignal(
                bars: currentBars,
                symbol: symbol,
                hasOpenPosition: hasPosition
            ) else {
                continue
            }

            // Handle position entry
            if signal.type == .buy && currentPosition == nil {
                let positionSize = calculatePositionSize(capital: capital, price: signal.price)

                currentPosition = Position(
                    symbol: symbol,
                    entryDate: signal.timestamp,
                    entryPrice: signal.price,
                    entrySignal: signal,
                    shares: positionSize.shares,
                    stopLoss: positionSize.stopLoss
                )
            }

            // Handle position exit
            if signal.type == .sell, var position = currentPosition {
                position.exitDate = signal.timestamp
                position.exitPrice = signal.price
                position.exitSignal = signal
                position.status = .closed

                // Create trade record
                let trade = Trade(
                    positionId: position.id,
                    symbol: symbol,
                    entryDate: position.entryDate,
                    entryPrice: position.entryPrice,
                    exitDate: signal.timestamp,
                    exitPrice: signal.price,
                    shares: position.shares,
                    entrySignal: position.entrySignal,
                    exitSignal: signal
                )

                trades.append(trade)

                // Update capital
                capital += trade.profitLoss

                // Clear position
                currentPosition = nil
            }

            // Check for stop loss
            if let position = currentPosition,
               shouldStopOut(currentPrice: signal.price, position: position) {
                var closedPosition = position
                closedPosition.exitDate = signal.timestamp
                closedPosition.exitPrice = position.stopLoss
                closedPosition.status = .closed

                // Create stop loss signal
                let stopLossSignal = Signal(
                    timestamp: signal.timestamp,
                    symbol: symbol,
                    type: .sell,
                    price: position.stopLoss,
                    indicators: signal.indicators,
                    cycleStage: signal.cycleStage,
                    reason: "Stop loss triggered"
                )

                closedPosition.exitSignal = stopLossSignal

                // Create trade record
                let trade = Trade(
                    positionId: closedPosition.id,
                    symbol: symbol,
                    entryDate: closedPosition.entryDate,
                    entryPrice: closedPosition.entryPrice,
                    exitDate: signal.timestamp,
                    exitPrice: position.stopLoss,
                    shares: closedPosition.shares,
                    entrySignal: closedPosition.entrySignal,
                    exitSignal: stopLossSignal
                )

                trades.append(trade)

                // Update capital
                capital += trade.profitLoss

                // Clear position
                currentPosition = nil
            }
        }

        return trades
    }
}
