//
//  ContentView.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SignalViewModel()

    var body: some View {
        TabView {
            // Trade Tab
            SignalView(viewModel: viewModel)
                .tabItem {
                    Label("Trade", systemImage: "chart.line.uptrend.xyaxis")
                }

            // Economy Tab
            EconomyView(viewModel: viewModel)
                .tabItem {
                    Label("Economy", systemImage: "globe.americas.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
