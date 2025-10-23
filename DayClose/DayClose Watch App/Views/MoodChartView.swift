//
//  MoodChartView.swift
//  DayClose Watch App
//
//  Visual chart for mood trends
//

import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct MoodChartView: View {
    let entries: [MoodEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("chart.title", comment: "7-Day Trend"))
                .font(.headline)
                .padding(.horizontal)

            #if canImport(Charts)
            if #available(watchOS 9.0, *) {
                chartView
            } else {
                simpleTrendView
            }
            #else
            simpleTrendView
            #endif
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    @available(watchOS 9.0, *)
    @ViewBuilder
    private var chartView: some View {
        #if canImport(Charts)
        Chart {
            ForEach(chartData, id: \.day) { data in
                LineMark(
                    x: .value("Day", data.day),
                    y: .value("Mood", data.score)
                )
                .foregroundStyle(Color.accentColor)
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Day", data.day),
                    y: .value("Mood", data.score)
                )
                .foregroundStyle(Color.accentColor)
                .symbolSize(40)
            }
        }
        .chartYScale(domain: 1...5)
        .chartYAxis {
            AxisMarks(position: .leading, values: [1, 2, 3, 4, 5]) { value in
                AxisValueLabel {
                    if let score = value.as(Int.self) {
                        Text(moodEmoji(for: score))
                            .font(.caption2)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 7)) { value in
                AxisValueLabel {
                    if let day = value.as(String.self) {
                        Text(day)
                            .font(.caption2)
                    }
                }
            }
        }
        .frame(height: 120)
        .padding(.horizontal, 8)
        #endif
    }

    private var chartData: [(day: String, score: Int)] {
        let calendar = Calendar.current
        let last7Days = (0..<7).compactMap { offset -> (day: String, score: Int)? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else {
                return nil
            }

            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE"
            let dayString = dayFormatter.string(from: date)

            // Find entry for this day
            if let entry = entries.first(where: { entry in
                guard let entryDate = entry.date else { return false }
                return calendar.isDate(entryDate, inSameDayAs: date)
            }), let mood = entry.mood {
                return (day: dayString, score: mood.score)
            }

            return (day: dayString, score: 3)  // Neutral for missing days
        }

        return last7Days.reversed()
    }

    private var simpleTrendView: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(chartData, id: \.day) { data in
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.accentColor.opacity(0.8))
                        .frame(width: 12, height: CGFloat(data.score * 12))

                    Text(data.day)
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(height: 80)
        .padding(.horizontal)
    }

    private func moodEmoji(for score: Int) -> String {
        switch score {
        case 5: return "🤩"
        case 4: return "😊"
        case 3: return "😐"
        case 2: return "😔"
        case 1: return "😢"
        default: return "😐"
        }
    }
}

#Preview {
    MoodChartView(entries: [])
}
