//
//  IndicatorSettings.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import Foundation
import Combine

class IndicatorSettings: ObservableObject {
    static let shared = IndicatorSettings()

    @Published var bollingerPeriod: Double {
        didSet { UserDefaults.standard.set(bollingerPeriod, forKey: "bollingerPeriod") }
    }

    @Published var bollingerStdDev: Double {
        didSet { UserDefaults.standard.set(bollingerStdDev, forKey: "bollingerStdDev") }
    }

    @Published var rsiPeriod: Double {
        didSet { UserDefaults.standard.set(rsiPeriod, forKey: "rsiPeriod") }
    }

    @Published var rsiOversold: Double {
        didSet { UserDefaults.standard.set(rsiOversold, forKey: "rsiOversold") }
    }

    @Published var rsiOverbought: Double {
        didSet { UserDefaults.standard.set(rsiOverbought, forKey: "rsiOverbought") }
    }

    @Published var keltnerPeriod: Double {
        didSet { UserDefaults.standard.set(keltnerPeriod, forKey: "keltnerPeriod") }
    }

    @Published var keltnerATRMultiplier: Double {
        didSet { UserDefaults.standard.set(keltnerATRMultiplier, forKey: "keltnerATRMultiplier") }
    }

    private init() {
        // Load from UserDefaults or use Constants defaults
        self.bollingerPeriod = UserDefaults.standard.object(forKey: "bollingerPeriod") as? Double ?? Double(Constants.Indicators.bollingerPeriod)
        self.bollingerStdDev = UserDefaults.standard.object(forKey: "bollingerStdDev") as? Double ?? Constants.Indicators.bollingerStdDev
        self.rsiPeriod = UserDefaults.standard.object(forKey: "rsiPeriod") as? Double ?? Double(Constants.Indicators.rsiPeriod)
        self.rsiOversold = UserDefaults.standard.object(forKey: "rsiOversold") as? Double ?? Constants.Indicators.rsiOversold
        self.rsiOverbought = UserDefaults.standard.object(forKey: "rsiOverbought") as? Double ?? Constants.Indicators.rsiOverbought
        self.keltnerPeriod = UserDefaults.standard.object(forKey: "keltnerPeriod") as? Double ?? Double(Constants.Indicators.keltnerPeriod)
        self.keltnerATRMultiplier = UserDefaults.standard.object(forKey: "keltnerATRMultiplier") as? Double ?? Constants.Indicators.keltnerATRMultiplier
    }

    func resetToDefaults() {
        bollingerPeriod = Double(Constants.Indicators.bollingerPeriod)
        bollingerStdDev = Constants.Indicators.bollingerStdDev
        rsiPeriod = Double(Constants.Indicators.rsiPeriod)
        rsiOversold = Constants.Indicators.rsiOversold
        rsiOverbought = Constants.Indicators.rsiOverbought
        keltnerPeriod = Double(Constants.Indicators.keltnerPeriod)
        keltnerATRMultiplier = Constants.Indicators.keltnerATRMultiplier
    }
}
