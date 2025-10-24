// this is the large buy signal at the top of the screen.

import SwiftUI

struct SignalCircleView: View {
    var signal: String = "BUY"
    var subtitle: String = "Momentum Rising"
    
    var body: some View {
        ZStack {
            // Background floating glow (now more visible)
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.80, green: 1.0, blue: 0.90),
                            Color(red: 0.60, green: 0.95, blue: 0.78)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 215, height: 215)
                //.blur(radius: 5)
                .offset(y: 0)
                .opacity(1.0) // More visible
                .shadow(color: Color.green.opacity(0.5), radius: 20, y: 10)
            
            // Main circle
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.38, green: 0.93, blue: 0.78),
                            Color(red: 0.10, green: 0.80, blue: 0.47)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 190, height: 190)
                .shadow(color: Color.green.opacity(0.2), radius: 25, x: 0, y: 12)
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
        .padding(40)
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
