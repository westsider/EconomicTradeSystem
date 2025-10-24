//
//  PolygonService.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import Foundation
import Combine

enum PolygonError: Error {
    case invalidURL
    case noData
    case decodingError
    case apiError(String)
    case networkError(Error)
}

struct PolygonResponse: Codable {
    let ticker: String
    let queryCount: Int
    let resultsCount: Int
    let adjusted: Bool
    let results: [PolygonBar]?
    let status: String
    let request_id: String?
    let count: Int?
}

struct PolygonBar: Codable {
    let v: Int64  // volume
    let vw: Double? // volume weighted average price
    let o: Double   // open
    let c: Double   // close
    let h: Double   // high
    let l: Double   // low
    let t: Int64    // timestamp (milliseconds)
    let n: Int?     // number of transactions
}

class PolygonService: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://api.polygon.io/v2/aggs/ticker"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    /// Fetch 30-minute bars for a given symbol
    /// - Parameters:
    ///   - symbol: Stock symbol (e.g., "GPIX")
    ///   - daysBack: Number of days of historical data to fetch
    /// - Returns: Array of PriceBar objects
    func fetch30MinBars(symbol: String, daysBack: Int = 90) async throws -> [PriceBar] {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -daysBack, to: endDate) ?? endDate

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fromDate = dateFormatter.string(from: startDate)
        let toDate = dateFormatter.string(from: endDate)

        // Build URL: /v2/aggs/ticker/{ticker}/range/{multiplier}/{timespan}/{from}/{to}
        let urlString = "\(baseURL)/\(symbol)/range/30/minute/\(fromDate)/\(toDate)?adjusted=true&sort=asc&limit=50000&apiKey=\(apiKey)"

        guard let url = URL(string: urlString) else {
            throw PolygonError.invalidURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw PolygonError.noData
            }

            // Debug logging
            print("📊 Polygon API Response:")
            print("   URL: \(urlString)")
            print("   Status Code: \(httpResponse.statusCode)")

            // Check for rate limiting
            if httpResponse.statusCode == 429 {
                throw PolygonError.apiError("Rate limit exceeded. Please wait before making more requests.")
            }

            // Check for other errors
            if httpResponse.statusCode != 200 {
                throw PolygonError.apiError("HTTP \(httpResponse.statusCode)")
            }

            let decoder = JSONDecoder()
            let polygonResponse = try decoder.decode(PolygonResponse.self, from: data)

            // Debug logging
            print("   Response Status: \(polygonResponse.status)")
            print("   Results Count: \(polygonResponse.resultsCount)")
            print("   Has Results: \(polygonResponse.results != nil)")

            // Check response status - accept both OK and DELAYED (free tier)
            if polygonResponse.status != "OK" && polygonResponse.status != "DELAYED" {
                throw PolygonError.apiError("API returned status: \(polygonResponse.status). Note: Free tier data is delayed 15 minutes.")
            }

            guard let results = polygonResponse.results, !results.isEmpty else {
                // Check if it's a market hours issue
                let calendar = Calendar.current
                let now = Date()
                let hour = calendar.component(.hour, from: now)
                let weekday = calendar.component(.weekday, from: now)

                // If weekend or outside market hours (9:30 AM - 4 PM ET is roughly 6:30 AM - 1 PM PT)
                if weekday == 1 || weekday == 7 {
                    throw PolygonError.noData // Weekend
                } else if hour < 6 || hour > 13 {
                    throw PolygonError.apiError("Market is closed. Data available during market hours (9:30 AM - 4 PM ET).")
                } else {
                    throw PolygonError.noData
                }
            }

            // Convert PolygonBar to PriceBar
            let priceBars = results.map { bar -> PriceBar in
                let timestamp = Date(timeIntervalSince1970: TimeInterval(bar.t) / 1000.0)
                return PriceBar(
                    timestamp: timestamp,
                    open: bar.o,
                    high: bar.h,
                    low: bar.l,
                    close: bar.c,
                    volume: bar.v
                )
            }

            return priceBars

        } catch let error as PolygonError {
            throw error
        } catch {
            throw PolygonError.networkError(error)
        }
    }

    /// Fetch the latest 30-minute bar for a given symbol
    /// - Parameter symbol: Stock symbol (e.g., "GPIX")
    /// - Returns: Latest PriceBar
    func fetchLatestBar(symbol: String) async throws -> PriceBar {
        let bars = try await fetch30MinBars(symbol: symbol, daysBack: 2)
        guard let latestBar = bars.last else {
            throw PolygonError.noData
        }
        return latestBar
    }

    /// Fetch real-time quote for a symbol
    /// - Parameter symbol: Stock symbol
    /// - Returns: Current price
    func fetchCurrentPrice(symbol: String) async throws -> Double {
        let urlString = "https://api.polygon.io/v2/last/trade/\(symbol)?apiKey=\(apiKey)"

        guard let url = URL(string: urlString) else {
            throw PolygonError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw PolygonError.apiError("Failed to fetch current price")
        }

        // Parse the response (simplified - you may need to adjust based on actual API response)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let results = json["results"] as? [String: Any],
           let price = results["p"] as? Double {
            return price
        }

        throw PolygonError.decodingError
    }
}
