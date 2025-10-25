// this is the large buy signal at the top of the screen.

import SwiftUI

struct SignalCircleView: View {
    var signal: String = "BUY"
    var subtitle: String = "Momentum Rising"

    private var colors: (bg: [Color], main: [Color], shadow: Color) {
        switch signal.uppercased() {
        case "BUY":
            return (
                bg: [Color(red: 0.80, green: 1.0, blue: 0.90), Color(red: 0.60, green: 0.95, blue: 0.78)],
                main: [Color(red: 0.38, green: 0.93, blue: 0.78), Color(red: 0.10, green: 0.80, blue: 0.47)],
                shadow: Color.green
            )
        case "SELL":
            return (
                bg: [Color(red: 1.0, green: 0.85, blue: 0.85), Color(red: 1.0, green: 0.70, blue: 0.70)],
                main: [Color(red: 1.0, green: 0.30, blue: 0.30), Color(red: 0.90, green: 0.10, blue: 0.10)],
                shadow: Color.red
            )
        case "HOLD":
            return (
                bg: [Color(red: 0.90, green: 0.90, blue: 0.92), Color(red: 0.78, green: 0.78, blue: 0.82)],
                main: [Color(red: 0.60, green: 0.60, blue: 0.65), Color(red: 0.45, green: 0.45, blue: 0.50)],
                shadow: Color.gray
            )
        default:
            return (
                bg: [Color(red: 0.90, green: 0.90, blue: 0.92), Color(red: 0.78, green: 0.78, blue: 0.82)],
                main: [Color(red: 0.60, green: 0.60, blue: 0.65), Color(red: 0.45, green: 0.45, blue: 0.50)],
                shadow: Color.gray
            )
        }
    }

    var body: some View {
        ZStack {
            // Background floating glow (now more visible)
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: colors.bg),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 215, height: 215)
                //.blur(radius: 5)
                .offset(y: 0)
                .opacity(1.0) // More visible
                .shadow(color: colors.shadow.opacity(0.5), radius: 20, y: 10)

            // Main circle
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: colors.main),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 190, height: 190)
                .shadow(color: colors.shadow.opacity(0.2), radius: 25, x: 0, y: 12)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        .blur(radius: 0.3)
                )
            
            // Text
            VStack(spacing: 8) {
                Text(signal)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.95))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            LinearGradient(
                colors: [
                    Color.white,
                    Color(red: 0.96, green: 0.98, blue: 0.97)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.8)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    SignalCircleView()
        .background(Color(.systemGray6))
}
