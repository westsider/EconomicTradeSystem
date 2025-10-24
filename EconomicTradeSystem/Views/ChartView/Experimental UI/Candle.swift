// this is a work in progress, please ignore this chart for now

import SwiftUI
import Charts

struct Candle: Identifiable {
    let id = UUID()
    let time: Date
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let upperBand: Double
    let middleBand: Double
    let lowerBand: Double
    let rsi: Double
}

struct CandlestickChartView: View {
    @State private var candles: [Candle] = generateSampleData()
    
    // 🔧 Computed dynamic y-axis range with padding
    private var priceRange: ClosedRange<Double> {
        let lows = candles.map { $0.low }
        let highs = candles.map { $0.high }
        guard let min = lows.min(), let max = highs.max() else { return 40...60 }
        let pad = (max - min) * 0.15   // 15% visual padding top/bottom
        return (min - pad)...(max + pad)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Candlestick + Bollinger Bands
            Chart(candles) { candle in
                // Candle wicks
                BarMark(
                    x: .value("Time", candle.time),
                    yStart: .value("Low", candle.low),
                    yEnd: .value("High", candle.high)
                )
                .foregroundStyle(Color.gray.opacity(0.4))
                
                // Candle body
                BarMark(
                    x: .value("Time", candle.time),
                    yStart: .value("Open", min(candle.open, candle.close)),
                    yEnd: .value("Close", max(candle.open, candle.close))
                )
                .foregroundStyle(candle.close >= candle.open ? Color.green.gradient : Color.red.gradient)
                .cornerRadius(2)
                
                // Bollinger Bands
                LineMark(x: .value("Time", candle.time), y: .value("Upper", candle.upperBand))
                    .foregroundStyle(Color.red.opacity(0.7))
                    .interpolationMethod(.catmullRom)
                
                LineMark(x: .value("Time", candle.time), y: .value("Middle", candle.middleBand))
                    .foregroundStyle(Color.blue.opacity(0.6))
                    .interpolationMethod(.catmullRom)
                
                LineMark(x: .value("Time", candle.time), y: .value("Lower", candle.lowerBand))
                    .foregroundStyle(Color.green.opacity(0.7))
                    .interpolationMethod(.catmullRom)
            }
            .chartYScale(domain: priceRange) // ✅ keeps chart zoomed on price range
            .chartYAxis {
                AxisMarks(position: .leading, values: .stride(by: 0.5))
            }
            .chartXAxis {
                AxisMarks(position: .bottom, values: .stride(by: .hour, count: 2))
            }
            .frame(height: 220)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            )
            
            // RSI Subchart (unchanged)
            Chart(candles) {
                LineMark(x: .value("Time", $0.time), y: .value("RSI", $0.rsi))
                    .foregroundStyle(Color.purple)
                    .interpolationMethod(.catmullRom)
                RuleMark(y: .value("Overbought", 70))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(Color.red.opacity(0.5))
                RuleMark(y: .value("Oversold", 30))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(Color.green.opacity(0.5))
            }
            .frame(height: 100)
            .chartYAxis {
                AxisMarks(values: [30, 50, 70])
            }
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            )
        }
        .padding()
    }
}

// MARK: - Sample Data Generator
extension CandlestickChartView {
    static func generateSampleData() -> [Candle] {
        let now = Date()
        return (0..<20).map { i in
            let base = 47.0 + Double.random(in: -1...1)
            return Candle(
                time: Calendar.current.date(byAdding: .minute, value: i * 30, to: now)!,
                open: base + Double.random(in: -0.3...0.3),
                high: base + Double.random(in: 0.3...0.8),
                low: base - Double.random(in: 0.3...0.8),
                close: base + Double.random(in: -0.4...0.4),
                upperBand: base + 0.9,
                middleBand: base,
                lowerBand: base - 0.9,
                rsi: Double.random(in: 25...75)
            )
        }
    }
}

#Preview {
    CandlestickChartView()
}
