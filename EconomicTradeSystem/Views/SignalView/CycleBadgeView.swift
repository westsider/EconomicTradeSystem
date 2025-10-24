//
//  CycleBadgeView.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//

import SwiftUI

struct CycleBadgeView: View {
    let stage: CycleStage

    var body: some View {
        VStack(spacing: Constants.Spacing.sm) {
            HStack(spacing: Constants.Spacing.sm) {
                Image(systemName: stage.icon)
                    .font(.system(size: 24))
                    .foregroundColor(stage.color)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Economic Cycle")
                        .font(Constants.Typography.caption)
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text(stage.rawValue)
                        .font(Constants.Typography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(stage.color)
                }

                Spacer()
            }

            Text(stage.description)
                .font(Constants.Typography.callout)
                .foregroundColor(Constants.Colors.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Constants.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Constants.Radius.large)
                .fill(Constants.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.Radius.large)
                        .stroke(stage.color.opacity(0.3), lineWidth: 2)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 16) {
        CycleBadgeView(stage: .expansion)
        CycleBadgeView(stage: .peak)
        CycleBadgeView(stage: .contraction)
        CycleBadgeView(stage: .recovery)
    }
    .padding()
    .background(Constants.Colors.background)
}
