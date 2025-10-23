//
//  DayCloseWidget.swift
//  DayClose Watch App
//
//  Smart Stack widget and complications
//

import WidgetKit
import SwiftUI

struct DayCloseWidget: Widget {
    let kind: String = "DayCloseWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DayCloseWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("widget.display.name", comment: ""))
        .description(NSLocalizedString("widget.description", comment: ""))
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), hasCheckedIn: false, mood: nil, message: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), hasCheckedIn: false, mood: nil, message: nil)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let controller = PersistenceController.shared
        let todayEntry = controller.fetchTodayEntry()
        
        let entry = SimpleEntry(
            date: currentDate,
            hasCheckedIn: todayEntry != nil,
            mood: todayEntry?.mood,
            message: todayEntry?.contextualMessage
        )
        
        // Refresh at midnight
        let midnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!)
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let hasCheckedIn: Bool
    let mood: MoodType?
    let message: String?
}

struct DayCloseWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularComplicationView(entry: entry)
        case .accessoryRectangular:
            RectangularComplicationView(entry: entry)
        case .accessoryInline:
            InlineComplicationView(entry: entry)
        default:
            CircularComplicationView(entry: entry)
        }
    }
}

struct CircularComplicationView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            
            if entry.hasCheckedIn, let mood = entry.mood {
                VStack(spacing: 2) {
                    Text(mood.emoji)
                        .font(.title2)
                    Text(mood.localizedLabel.prefix(3))
                        .font(.caption2)
                        .textCase(.uppercase)
                }
            } else {
                VStack(spacing: 2) {
                    Image(systemName: "circle.dashed")
                        .font(.title2)
                    Text("LOG")
                        .font(.caption2)
                }
            }
        }
    }
}

struct RectangularComplicationView: View {
    let entry: SimpleEntry
    
    var body: some View {
        if entry.hasCheckedIn, let mood = entry.mood {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text(NSLocalizedString("widget.checked.in", comment: ""))
                        .font(.headline)
                }
                
                HStack {
                    Text(mood.emoji)
                    Text(mood.localizedLabel)
                        .font(.caption)
                }
            }
        } else {
            VStack(alignment: .leading, spacing: 4) {
                Text(NSLocalizedString("widget.prompt.title", comment: ""))
                    .font(.headline)
                Text(NSLocalizedString("widget.prompt.subtitle", comment: ""))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct InlineComplicationView: View {
    let entry: SimpleEntry
    
    var body: some View {
        if entry.hasCheckedIn, let mood = entry.mood {
            Label("\(mood.emoji) \(mood.localizedLabel)", systemImage: "checkmark")
        } else {
            Label(NSLocalizedString("widget.inline.prompt", comment: ""), systemImage: "circle.dashed")
        }
    }
}

#Preview("Circular", as: .accessoryCircular) {
    DayCloseWidget()
} timeline: {
    SimpleEntry(date: .now, hasCheckedIn: false, mood: nil, message: nil)
    SimpleEntry(date: .now, hasCheckedIn: true, mood: .good, message: "Great day!")
}

#Preview("Rectangular", as: .accessoryRectangular) {
    DayCloseWidget()
} timeline: {
    SimpleEntry(date: .now, hasCheckedIn: false, mood: nil, message: nil)
    SimpleEntry(date: .now, hasCheckedIn: true, mood: .neutral, message: "Steady day")
}
