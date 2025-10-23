//
//  TrendView.swift
//  DayClose Watch App
//
//  7-day history and trend analysis
//

import SwiftUI
import CoreData

struct TrendView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MoodEntry.date, ascending: false)],
        animation: .default
    )
    private var entries: FetchedResults<MoodEntry>
    
    @State private var showingAnalysis = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 4) {
                    Text(NSLocalizedString("trend.title", comment: ""))
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(NSLocalizedString("trend.subtitle", comment: ""))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top)
                
                if entries.isEmpty {
                    emptyStateView
                } else {
                    // Entry list
                    LazyVStack(spacing: 12) {
                        ForEach(Array(entries.prefix(7)), id: \.id) { entry in
                            TrendEntryCard(entry: entry)
                        }
                    }
                    
                    // Trend analysis button
                    if entries.count >= 3 {
                        Button {
                            showingAnalysis = true
                        } label: {
                            Label(NSLocalizedString("trend.analysis.button", comment: ""), systemImage: "chart.line.uptrend.xyaxis")
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 8)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(NSLocalizedString("trend.navigation.title", comment: ""))
        .sheet(isPresented: $showingAnalysis) {
            TrendAnalysisView(entries: Array(entries.prefix(7)))
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            
            Text(NSLocalizedString("trend.empty.message", comment: ""))
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

struct TrendEntryCard: View {
    let entry: MoodEntry
    
    var body: some View {
        HStack(spacing: 12) {
            // Mood emoji
            if let mood = entry.mood {
                Text(mood.emoji)
                    .font(.title2)
            }
            
            // Date and details
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(.headline)
                
                if let mood = entry.mood {
                    Text(mood.localizedLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Health metrics indicator
                if entry.hrvValue > 0 || entry.activityRingCompletion > 0 {
                    HStack(spacing: 4) {
                        if entry.activityRingCompletion > 0 {
                            Image(systemName: "figure.walk")
                                .font(.caption2)
                            Text("\(Int(entry.activityRingCompletion * 100))%")
                                .font(.caption2)
                        }
                        
                        if entry.hrvValue > 0 {
                            Image(systemName: "heart.fill")
                                .font(.caption2)
                        }
                    }
                    .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
    
    private var formattedDate: String {
        guard let date = entry.date else { return "" }
        
        if Calendar.current.isDateInToday(date) {
            return NSLocalizedString("trend.today", comment: "")
        } else if Calendar.current.isDateInYesterday(date) {
            return NSLocalizedString("trend.yesterday", comment: "")
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, MMM d"
            return formatter.string(from: date)
        }
    }
    
    private var accessibilityLabel: String {
        var label = formattedDate
        if let mood = entry.mood {
            label += ", \(mood.localizedLabel)"
        }
        return label
    }
}

struct TrendAnalysisView: View {
    let entries: [MoodEntry]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    let analysis = InsightsEngine.shared.analyzeTrend(entries: entries)
                    
                    // Trend icon
                    Image(systemName: trendIcon(analysis.trend))
                        .font(.system(size: 50))
                        .foregroundStyle(trendColor(analysis.trend))
                    
                    // Trend message
                    Text(analysis.message)
                        .font(.body)
                        .multilineTextAlignment(.center)
                    
                    // Mood distribution
                    VStack(alignment: .leading, spacing: 12) {
                        Text(NSLocalizedString("trend.distribution.title", comment: ""))
                            .font(.headline)
                        
                        let distribution = PersistenceController.shared.getMoodDistribution(days: 7)
                        
                        ForEach(MoodType.allCases, id: \.self) { mood in
                            HStack {
                                Text(mood.emoji)
                                Text(mood.localizedLabel)
                                    .font(.body)
                                Spacer()
                                Text("\(distribution[mood] ?? 0)")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("trend.analysis.title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("common.done", comment: "")) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func trendIcon(_ trend: TrendAnalysis.Trend) -> String {
        switch trend {
        case .improving: return "arrow.up.circle.fill"
        case .stable: return "arrow.left.and.right.circle.fill"
        case .declining: return "arrow.down.circle.fill"
        }
    }
    
    private func trendColor(_ trend: TrendAnalysis.Trend) -> Color {
        switch trend {
        case .improving: return .green
        case .stable: return .blue
        case .declining: return .orange
        }
    }
}

#Preview {
    TrendView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
