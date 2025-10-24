//
//  ExpansionButton.swift
//  EconomicTradeSystem
//
//  Created by Warren Hansen on 10/24/25.
//  this is a custom rounded button, use it wherever you think the design works well


import SwiftUI

struct ExpansionButton: View {
    var title: String = "Expansion"
    var gradient: Gradient = Gradient(colors: [
        Color(red: 0.38, green: 0.93, blue: 0.78),
        Color(red: 0.10, green: 0.80, blue: 0.47)
    ])
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 30)
            .background(
                LinearGradient(gradient: gradient,
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .cornerRadius(28)
                    .shadow(color: Color.green.opacity(0.25), radius: 12, x: 0, y: 6)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 30) {
        ExpansionButton()
        ExpansionButton(title: "Recovery", gradient: Gradient(colors: [Color.blue, Color.cyan]))
    }
    .padding()
    .background(Color(.systemGray6))
}
