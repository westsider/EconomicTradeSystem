//
//  Extensions.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import SwiftUI

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Double Extensions
extension Double {
    func formatAsCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }

    func formatAsPercent(decimals: Int = 2) -> String {
        String(format: "%.\(decimals)f%%", self)
    }

    func formatAsDecimal(decimals: Int = 2) -> String {
        String(format: "%.\(decimals)f", self)
    }
}

// MARK: - Date Extensions
extension Date {
    func formatAsTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: self)
    }

    func formatAsDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: self)
    }

    func formatAsDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: self)
    }

    func formatAsShortDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        return formatter.string(from: self)
    }
}

// MARK: - Array Extensions
extension Array where Element == PriceBar {
    func sma(period: Int) -> [Double] {
        var results: [Double] = []
        for i in 0..<count {
            if i < period - 1 {
                results.append(0)
            } else {
                let slice = self[(i - period + 1)...i]
                let sum = slice.reduce(0.0) { $0 + $1.close }
                results.append(sum / Double(period))
            }
        }
        return results
    }

    func ema(period: Int) -> [Double] {
        var results: [Double] = []
        let multiplier = 2.0 / Double(period + 1)

        for i in 0..<count {
            if i == 0 {
                results.append(self[i].close)
            } else {
                let ema = (self[i].close - results[i - 1]) * multiplier + results[i - 1]
                results.append(ema)
            }
        }
        return results
    }
}

extension Array where Element == Double {
    func standardDeviation() -> Double {
        guard !isEmpty else { return 0 }
        let mean = reduce(0, +) / Double(count)
        let variance = map { pow($0 - mean, 2) }.reduce(0, +) / Double(count)
        return sqrt(variance)
    }
}
