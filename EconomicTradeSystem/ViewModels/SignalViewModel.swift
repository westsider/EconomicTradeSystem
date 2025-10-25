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
    @Published var currentEconomicData: EconomicData?
    @Published var cycleStageHistory: [(date: Date, stage: CycleStage)] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedSymbol: String = Constants.Trading.defaultSymbol
    @Published var lastUpdateTime: Date?

    // MARK: - Services
    var polygonService: PolygonService?
    private var fredService: FREDService?
    private var cycleClassifier: EconomicCycleClassifier?
    private var updateTimer: Timer?

    // MARK: - Initialization
    init() {
        setupPolygonService()
        setupFREDService()
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

    // MARK: - Setup FRED Service
    func setupFREDService() {
        // Always use the default FRED API key for now
        let defaultKey = "ebde2f9652163f7bc1694fa764f8ea44"

        // Check if there's a stored key
        if KeychainManager.shared.hasFREDAPIKey() {
            do {
                let storedKey = try KeychainManager.shared.getFREDAPIKey()
                print("📊 Found stored FRED key: \(String(storedKey.prefix(8)))... (length: \(storedKey.count))")

                // Validate it's a proper FRED key (32 lowercase alphanumeric)
                let isValid = storedKey.count == 32 && storedKey.allSatisfy { $0.isLetter || $0.isNumber } && storedKey.lowercased() == storedKey

                if isValid {
                    print("✅ Using stored FRED API key")
                    fredService = FREDService(apiKey: storedKey)
                    cycleClassifier = EconomicCycleClassifier()
                } else {
                    print("⚠️ Stored FRED key is invalid format - deleting and using default")
                    try? KeychainManager.shared.deleteFREDAPIKey()
                    fredService = FREDService(apiKey: defaultKey)
                    cycleClassifier = EconomicCycleClassifier()
                }
            } catch {
                print("⚠️ Error reading FRED key - using default: \(error)")
                fredService = FREDService(apiKey: defaultKey)
                cycleClassifier = EconomicCycleClassifier()
            }
        } else {
            // No stored key - use default
            print("⚠️ No FRED API key configured - using free public key: \(String(defaultKey.prefix(8)))...")
            fredService = FREDService(apiKey: defaultKey)
            cycleClassifier = EconomicCycleClassifier()
        }

        // Trigger fetching economic cycle data
        fetchEconomicCycle()
    }

    // MARK: - Fetch Economic Cycle
    private func fetchEconomicCycle() {
        guard let fredService = fredService,
              let classifier = cycleClassifier else {
            print("⚠️ FRED service or classifier not initialized")
            return
        }

        Task {
            do {
                print("📊 Fetching economic data from FRED...")
                // Fetch economic data from FRED
                let economicData = try await fredService.fetchAllIndicators(startDate: "2020-01-01")
                print("📊 Received \(economicData.count) economic data points")

                // Classify into cycle stages
                let _ = classifier.classify(data: economicData)

                // Get current stage and history
                if let currentStage = classifier.getCurrentStage() {
                    await MainActor.run {
                        self.cycleStage = currentStage
                        self.cycleStageHistory = classifier.classify(data: economicData)
                        self.currentEconomicData = economicData.last
                        print("✅ Economic Cycle Stage: \(currentStage.rawValue)")
                        print("✅ Economic Data: GDP=\(economicData.last?.gdpGrowth ?? 0), Unemployment=\(economicData.last?.unemployment ?? 0)")
                    }
                } else {
                    print("⚠️ No current stage available")
                }
            } catch {
                print("❌ Failed to fetch economic cycle: \(error)")
                if let fredError = error as? FREDError {
                    print("❌ FRED Error details: \(fredError)")
                }
                // Don't show error to user - cycle is optional
            }
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
