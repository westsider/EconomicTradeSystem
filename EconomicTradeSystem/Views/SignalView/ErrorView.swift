//
//  ErrorView.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: Constants.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.sellRed)

            VStack(spacing: Constants.Spacing.sm) {
                Text("Error")
                    .font(Constants.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.primaryText)

                Text(message)
                    .font(Constants.Typography.body)
                    .foregroundColor(Constants.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.Spacing.xl)
            }

            Button(action: onRetry) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .font(Constants.Typography.headline)
                .foregroundColor(.white)
                .padding(.horizontal, Constants.Spacing.xl)
                .padding(.vertical, Constants.Spacing.md)
                .background(Constants.Colors.accent)
                .cornerRadius(Constants.Radius.medium)
            }
        }
        .padding(Constants.Spacing.xl)
    }
}

#Preview {
    ErrorView(message: "Failed to fetch data. Please check your internet connection and try again.") {
        print("Retry tapped")
    }
    .background(Constants.Colors.background)
}
