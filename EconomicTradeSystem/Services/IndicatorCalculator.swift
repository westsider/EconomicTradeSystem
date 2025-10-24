//
//  IndicatorCalculator.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import Foundation

class IndicatorCalculator {
    // MARK: - Bollinger Bands
    static func calculateBollingerBands(
        bars: [PriceBar],
        period: Int = Constants.Indicators.bollingerPeriod,
        stdDev: Double = Constants.Indicators.bollingerStdDev
    ) -> [(upper: Double, middle: Double, lower: Double)] {
        var results: [(upper: Double, middle: Double, lower: Double)] = []

        for i in 0..<bars.count {
            if i < period - 1 {
                results.append((0, 0, 0))
            } else {
                let slice = bars[(i - period + 1)...i]
                let closes = slice.map { $0.close }
                let sma = closes.reduce(0, +) / Double(period)
                let variance = closes.map { pow($0 - sma, 2) }.reduce(0, +) / Double(period)
                let std = sqrt(variance)

                let upper = sma + (std * stdDev)
                let lower = sma - (std * stdDev)

                results.append((upper: upper, middle: sma, lower: lower))
            }
        }

        return results
    }

    // MARK: - RSI (Relative Strength Index)
    static func calculateRSI(
        bars: [PriceBar],
        period: Int = Constants.Indicators.rsiPeriod
    ) -> [Double] {
        var results: [Double] = []
        var gains: [Double] = []
        var losses: [Double] = []

        for i in 0..<bars.count {
            if i == 0 {
                results.append(50) // Neutral RSI for first bar
                continue
            }

            let change = bars[i].close - bars[i - 1].close
            gains.append(max(change, 0))
            losses.append(max(-change, 0))

            if i < period {
                results.append(50) // Not enough data yet
            } else {
                let recentGains = gains.suffix(period)
                let recentLosses = losses.suffix(period)

                let avgGain = recentGains.reduce(0, +) / Double(period)
                let avgLoss = recentLosses.reduce(0, +) / Double(period)

                if avgLoss == 0 {
                    results.append(100)
                } else {
                    let rs = avgGain / avgLoss
                    let rsi = 100 - (100 / (1 + rs))
                    results.append(rsi)
                }
            }
        }

        return results
    }

    // MARK: - Keltner Channel
    static func calculateKeltnerChannel(
        bars: [PriceBar],
        period: Int = Constants.Indicators.keltnerPeriod,
        atrMultiplier: Double = Constants.Indicators.keltnerATRMultiplier
    ) -> [(upper: Double, middle: Double, lower: Double)] {
        var results: [(upper: Double, middle: Double, lower: Double)] = []

        // Calculate EMA of close
        let emaValues = calculateEMA(bars: bars, period: period)

        // Calculate ATR
        let atrValues = calculateATR(bars: bars, period: period)

        for i in 0..<bars.count {
            if i < period - 1 {
                results.append((0, 0, 0))
            } else {
                let middle = emaValues[i]
                let atr = atrValues[i]
                let upper = middle + (atr * atrMultiplier)
                let lower = middle - (atr * atrMultiplier)

                results.append((upper: upper, middle: middle, lower: lower))
            }
        }

        return results
    }

    // MARK: - EMA (Exponential Moving Average)
    static func calculateEMA(bars: [PriceBar], period: Int) -> [Double] {
        var results: [Double] = []
        let multiplier = 2.0 / Double(period + 1)

        for i in 0..<bars.count {
            if i == 0 {
                results.append(bars[i].close)
            } else if i < period {
                // Use SMA for initial values
                let slice = bars[0...i]
                let sma = slice.map { $0.close }.reduce(0, +) / Double(i + 1)
                results.append(sma)
            } else {
                let ema = (bars[i].close - results[i - 1]) * multiplier + results[i - 1]
                results.append(ema)
            }
        }

        return results
    }

    // MARK: - ATR (Average True Range)
    static func calculateATR(bars: [PriceBar], period: Int) -> [Double] {
        var results: [Double] = []
        var trueRanges: [Double] = []

        for i in 0..<bars.count {
            if i == 0 {
                trueRanges.append(bars[i].high - bars[i].low)
                results.append(trueRanges[i])
            } else {
                let highLow = bars[i].high - bars[i].low
                let highClose = abs(bars[i].high - bars[i - 1].close)
                let lowClose = abs(bars[i].low - bars[i - 1].close)
                let trueRange = max(highLow, max(highClose, lowClose))

                trueRanges.append(trueRange)

                if i < period {
                    // Calculate SMA of true ranges
                    let atr = trueRanges.reduce(0, +) / Double(trueRanges.count)
                    results.append(atr)
                } else {
                    // Calculate smoothed ATR
                    let atr = (results[i - 1] * Double(period - 1) + trueRange) / Double(period)
                    results.append(atr)
                }
            }
        }

        return results
    }

    // MARK: - SMA (Simple Moving Average)
    static func calculateSMA(bars: [PriceBar], period: Int) -> [Double] {
        var results: [Double] = []

        for i in 0..<bars.count {
            if i < period - 1 {
                results.append(0)
            } else {
                let slice = bars[(i - period + 1)...i]
                let sum = slice.map { $0.close }.reduce(0, +)
                results.append(sum / Double(period))
            }
        }

        return results
    }

    // MARK: - MACD (Moving Average Convergence Divergence)
    static func calculateMACD(
        bars: [PriceBar],
        fastPeriod: Int = 12,
        slowPeriod: Int = 26,
        signalPeriod: Int = 9
    ) -> [(macd: Double, signal: Double, histogram: Double)] {
        var results: [(macd: Double, signal: Double, histogram: Double)] = []

        let fastEMA = calculateEMA(bars: bars, period: fastPeriod)
        let slowEMA = calculateEMA(bars: bars, period: slowPeriod)

        var macdLine: [Double] = []
        for i in 0..<bars.count {
            macdLine.append(fastEMA[i] - slowEMA[i])
        }

        // Calculate signal line (EMA of MACD)
        var signalLine: [Double] = []
        let multiplier = 2.0 / Double(signalPeriod + 1)

        for i in 0..<macdLine.count {
            if i == 0 {
                signalLine.append(macdLine[i])
            } else if i < signalPeriod {
                let sma = macdLine[0...i].reduce(0, +) / Double(i + 1)
                signalLine.append(sma)
            } else {
                let signal = (macdLine[i] - signalLine[i - 1]) * multiplier + signalLine[i - 1]
                signalLine.append(signal)
            }
        }

        // Calculate histogram
        for i in 0..<bars.count {
            let histogram = macdLine[i] - signalLine[i]
            results.append((macd: macdLine[i], signal: signalLine[i], histogram: histogram))
        }

        return results
    }

    // MARK: - Calculate All Indicators for a Bar
    static func calculateIndicators(
        bars: [PriceBar],
        index: Int
    ) -> TechnicalIndicators? {
        guard index >= 0 && index < bars.count else { return nil }

        // Need at least 20 bars for calculations
        guard bars.count >= Constants.Indicators.bollingerPeriod else { return nil }

        let bollingerBands = calculateBollingerBands(bars: bars)
        let rsiValues = calculateRSI(bars: bars)
        let keltnerChannel = calculateKeltnerChannel(bars: bars)
        let atrValues = calculateATR(bars: bars, period: 14)

        let bb = bollingerBands[index]
        let rsi = rsiValues[index]
        let kc = keltnerChannel[index]
        let atr = atrValues[index]

        return TechnicalIndicators(
            bollingerUpper: bb.upper,
            bollingerMiddle: bb.middle,
            bollingerLower: bb.lower,
            rsi: rsi,
            keltnerUpper: kc.upper,
            keltnerLower: kc.lower,
            atr: atr
        )
    }
}
