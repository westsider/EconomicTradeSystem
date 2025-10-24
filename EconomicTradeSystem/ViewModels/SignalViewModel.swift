//
//  SignalViewModel.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class SignalViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentSignal: Signal?
    @Published var currentPosition: Position?
    @Published var priceBars: [PriceBar] = []
    @Published var cycleStage: CycleStage?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedSymbol: String = Constants.Trading.defaultSymbol
    @Published var lastUpdateTime: Date?

    // MARK: - Services
    private var polygonService: PolygonService?
    private var updateTimer: Timer?

    // MARK: - Initialization
    init() {
        setupPolygonService()
    }

    // MARK: - Setup Polygon Service
    private func setupPolygonService() {
        do {
            let apiKey = try KeychainManager.shared.getPolygonAPIKey()
            polygonService = PolygonService(apiKey: apiKey)
        } catch {
            errorMessage = "Please configure your Polygon.io API key in Settings"
        }
    }

    // MARK: - Fetch Latest Data
    func fetchLatestData() async {
        guard let polygonService = polygonService else {
            errorMessage = "Polygon service not configured"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // Fetch 30-minute bars
            let bars = try await polygonService.fetch30MinBars(symbol: selectedSymbol, daysBack: 90)
            priceBars = bars

            // Generate current signal
            let hasPosition = currentPosition != nil
            if let signal = SignalGenerator.generateSignal(
                bars: bars,
                symbol: selectedSymbol,
                cycleStage: cycleStage,
                hasOpenPosition: hasPosition
            ) {
                // Check if signal changed
                let signalChanged = currentSignal?.type != signal.type

                currentSignal = signal
                lastUpdateTime = Date()

                // Send notification if signal changed
                if signalChanged {
                    sendSignalNotification(signal: signal)
                }

                // Handle position updates
                updatePosition(with: signal)
            }

            isLoading = false
        } catch let error as PolygonError {
            isLoading = false
            switch error {
            case .apiError(let message):
                errorMessage = message
            case .noData:
                errorMessage = "No data available for \(selectedSymbol)"
            case .invalidURL:
                errorMessage = "Invalid API request"
            case .decodingError:
                errorMessage = "Failed to parse data"
            case .networkError(let err):
                errorMessage = "Network error: \(err.localizedDescription)"
            }
        } catch {
            isLoading = false
            errorMessage = "Failed to fetch data: \(error.localizedDescription)"
        }
    }

    // MARK: - Update Position
    private func updatePosition(with signal: Signal) {
        // Handle buy signal - open position
        if signal.type == .buy && currentPosition == nil {
            let positionSize = SignalGenerator.calculatePositionSize(
                capital: Constants.Trading.defaultCapital,
                price: signal.price
            )

            currentPosition = Position(
                symbol: selectedSymbol,
                entryDate: signal.timestamp,
                entryPrice: signal.price,
                entrySignal: signal,
                shares: positionSize.shares,
                stopLoss: positionSize.stopLoss
            )
        }

        // Handle sell signal - close position
        if signal.type == .sell, var position = currentPosition {
            position.exitDate = signal.timestamp
            position.exitPrice = signal.price
            position.exitSignal = signal
            position.status = .closed

            // Clear position (in a real app, you'd save this to history)
            currentPosition = nil
        }

        // Check stop loss
        if let position = currentPosition,
           SignalGenerator.shouldStopOut(currentPrice: signal.price, position: position) {
            var closedPosition = position
            closedPosition.exitDate = signal.timestamp
            closedPosition.exitPrice = position.stopLoss
            closedPosition.status = .closed

            // Create stop loss signal
            let stopLossSignal = Signal(
                timestamp: signal.timestamp,
                symbol: selectedSymbol,
                type: .sell,
                price: position.stopLoss,
                indicators: signal.indicators,
                cycleStage: cycleStage,
                reason: "Stop loss triggered at \(position.stopLoss.formatAsCurrency())"
            )
            closedPosition.exitSignal = stopLossSignal

            currentPosition = nil
            currentSignal = stopLossSignal
        }
    }

    // MARK: - Send Notification
    private func sendSignalNotification(signal: Signal) {
        // TODO: Implement push notifications
        print("📢 Signal changed: \(signal.type.rawValue) at \(signal.formattedPrice)")
    }

    // MARK: - Start Auto-Update Timer
    func startAutoUpdate() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: Constants.Updates.barInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchLatestData()
            }
        }
    }

    // MARK: - Stop Auto-Update Timer
    func stopAutoUpdate() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    // MARK: - Change Symbol
    func changeSymbol(to symbol: String) {
        selectedSymbol = symbol
        currentSignal = nil
        currentPosition = nil
        priceBars = []
        Task {
            await fetchLatestData()
        }
    }

    // MARK: - Refresh
    func refresh() async {
        await fetchLatestData()
    }

    // MARK: - Configure API Key
    func configureAPIKey(_ apiKey: String) {
        do {
            try KeychainManager.shared.savePolygonAPIKey(apiKey)
            setupPolygonService()
            Task {
                await fetchLatestData()
            }
        } catch {
            errorMessage = "Failed to save API key: \(error.localizedDescription)"
        }
    }
}
