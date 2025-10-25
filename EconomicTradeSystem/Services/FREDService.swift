//
//  FREDService.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/25/25.
//

import Foundation

enum FREDError: Error {
    case invalidURL
    case noData
    case apiError(String)
    case decodingError
    case networkError(Error)
}

struct EconomicData {
    let date: Date
    var gdpGrowth: Double?
    var unemployment: Double?
    var inflation: Double?
    var yieldCurve: Double?
    var fedFunds: Double?
    var consumerSentiment: Double?

    // Calculated fields
    var gdpTrend: Double?
    var unemploymentTrend: Double?
}

class FREDService {
    private let apiKey: String
    private let baseURL = Constants.API.fredBaseURL

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // MARK: - Fetch Single Series
    func fetchSeries(seriesID: String, startDate: String) async throws -> [FREDObservation] {
        guard var components = URLComponents(string: "\(baseURL)/series/observations") else {
            throw FREDError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "series_id", value: seriesID),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "file_type", value: "json"),
            URLQueryItem(name: "observation_start", value: startDate)
        ]

        guard let url = components.url else {
            throw FREDError.invalidURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw FREDError.apiError("Invalid HTTP response")
            }

            // Log the response for debugging
            print("📊 FRED API Response for \(seriesID):")
            print("   Status Code: \(httpResponse.statusCode)")
            print("   URL: \(url.absoluteString)")

            guard httpResponse.statusCode == 200 else {
                // Try to parse error message from response
                if let errorString = String(data: data, encoding: .utf8) {
                    print("   Error Response: \(errorString)")
                }
                throw FREDError.apiError("HTTP \(httpResponse.statusCode)")
            }

            // Try to decode the response
            do {
                let fredResponse = try JSONDecoder().decode(FREDResponse.self, from: data)
                print("   Observations Count: \(fredResponse.observations.count)")
                return fredResponse.observations
            } catch {
                // Log decoding error with sample of response
                if let responseString = String(data: data, encoding: .utf8) {
                    let preview = String(responseString.prefix(500))
                    print("   Decoding Error: \(error)")
                    print("   Response Preview: \(preview)")
                }
                throw FREDError.decodingError
            }
        } catch let error as FREDError {
            throw error
        } catch {
            throw FREDError.networkError(error)
        }
    }

    // MARK: - Fetch All Economic Indicators
    func fetchAllIndicators(startDate: String = "2020-01-01") async throws -> [EconomicData] {
        // Fetch all series in parallel
        async let gdpData = fetchSeries(seriesID: Constants.API.FREDSeries.gdpGrowth, startDate: startDate)
        async let unemploymentData = fetchSeries(seriesID: Constants.API.FREDSeries.unemployment, startDate: startDate)
        async let cpiData = fetchSeries(seriesID: Constants.API.FREDSeries.cpi, startDate: startDate)
        async let fedFundsData = fetchSeries(seriesID: Constants.API.FREDSeries.fedFunds, startDate: startDate)
        async let treasury10YData = fetchSeries(seriesID: Constants.API.FREDSeries.treasury10Y, startDate: startDate)
        async let treasury2YData = fetchSeries(seriesID: Constants.API.FREDSeries.treasury2Y, startDate: startDate)
        async let sentimentData = fetchSeries(seriesID: Constants.API.FREDSeries.consumerSentiment, startDate: startDate)

        // Await all results
        let (gdp, unemp, cpi, fedFunds, treasury10, treasury2, sentiment) = try await (
            gdpData, unemploymentData, cpiData, fedFundsData,
            treasury10YData, treasury2YData, sentimentData
        )

        // Combine all series into dictionary by date
        var dataByDate: [String: EconomicData] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        // Process GDP
        for obs in gdp {
            guard let value = Double(obs.value), obs.value != "." else { continue }
            var data = dataByDate[obs.date] ?? EconomicData(
                date: dateFormatter.date(from: obs.date) ?? Date(),
                gdpGrowth: nil, unemployment: nil, inflation: nil,
                yieldCurve: nil, fedFunds: nil, consumerSentiment: nil
            )
            var updatedData = data
            updatedData.gdpGrowth = value
            dataByDate[obs.date] = updatedData
        }

        // Process Unemployment
        for obs in unemp {
            guard let value = Double(obs.value), obs.value != "." else { continue }
            var data = dataByDate[obs.date] ?? EconomicData(
                date: dateFormatter.date(from: obs.date) ?? Date(),
                gdpGrowth: nil, unemployment: nil, inflation: nil,
                yieldCurve: nil, fedFunds: nil, consumerSentiment: nil
            )
            var updatedData = data
            updatedData.unemployment = value
            dataByDate[obs.date] = updatedData
        }

        // Process Fed Funds
        for obs in fedFunds {
            guard let value = Double(obs.value), obs.value != "." else { continue }
            var data = dataByDate[obs.date] ?? EconomicData(
                date: dateFormatter.date(from: obs.date) ?? Date(),
                gdpGrowth: nil, unemployment: nil, inflation: nil,
                yieldCurve: nil, fedFunds: nil, consumerSentiment: nil
            )
            var updatedData = data
            updatedData.fedFunds = value
            dataByDate[obs.date] = updatedData
        }

        // Process Consumer Sentiment
        for obs in sentiment {
            guard let value = Double(obs.value), obs.value != "." else { continue }
            var data = dataByDate[obs.date] ?? EconomicData(
                date: dateFormatter.date(from: obs.date) ?? Date(),
                gdpGrowth: nil, unemployment: nil, inflation: nil,
                yieldCurve: nil, fedFunds: nil, consumerSentiment: nil
            )
            var updatedData = data
            updatedData.consumerSentiment = value
            dataByDate[obs.date] = updatedData
        }

        // Calculate yield curve (10Y - 2Y)
        let treasury10Dict = Dictionary(uniqueKeysWithValues: treasury10.compactMap { obs -> (String, Double)? in
            guard let value = Double(obs.value), obs.value != "." else { return nil }
            return (obs.date, value)
        })
        let treasury2Dict = Dictionary(uniqueKeysWithValues: treasury2.compactMap { obs -> (String, Double)? in
            guard let value = Double(obs.value), obs.value != "." else { return nil }
            return (obs.date, value)
        })

        for date in Set(treasury10Dict.keys).intersection(Set(treasury2Dict.keys)) {
            if let t10 = treasury10Dict[date], let t2 = treasury2Dict[date] {
                var data = dataByDate[date] ?? EconomicData(
                    date: dateFormatter.date(from: date) ?? Date(),
                    gdpGrowth: nil, unemployment: nil, inflation: nil,
                    yieldCurve: nil, fedFunds: nil, consumerSentiment: nil
                )
                var updatedData = data
                updatedData.yieldCurve = t10 - t2
                dataByDate[date] = updatedData
            }
        }

        // Calculate inflation (year-over-year CPI change)
        let cpiDict = Dictionary(uniqueKeysWithValues: cpi.compactMap { obs -> (String, Double)? in
            guard let value = Double(obs.value), obs.value != "." else { return nil }
            return (obs.date, value)
        })

        let sortedCPIDates = cpiDict.keys.sorted()
        for (index, date) in sortedCPIDates.enumerated() {
            if index >= 12, let currentCPI = cpiDict[date] {
                let yearAgoDate = sortedCPIDates[index - 12]
                if let yearAgoCPI = cpiDict[yearAgoDate] {
                    let inflation = ((currentCPI - yearAgoCPI) / yearAgoCPI) * 100
                    var data = dataByDate[date] ?? EconomicData(
                        date: dateFormatter.date(from: date) ?? Date(),
                        gdpGrowth: nil, unemployment: nil, inflation: nil,
                        yieldCurve: nil, fedFunds: nil, consumerSentiment: nil
                    )
                    var updatedData = data
                    updatedData.inflation = inflation
                    dataByDate[date] = updatedData
                }
            }
        }

        // Convert to sorted array
        return dataByDate.values.sorted { $0.date < $1.date }
    }
}

// MARK: - FRED API Response Models
struct FREDResponse: Codable {
    let observations: [FREDObservation]
}

struct FREDObservation: Codable {
    let date: String
    let value: String
}
