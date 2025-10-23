//
//  DayCloseIntents.swift
//  DayClose Watch App
//
//  App Intents for Shortcuts and Siri integration
//

import AppIntents
import SwiftUI

// MARK: - Quick Mood Entry Intent

struct QuickMoodEntryIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Mood"
    static var description: IntentDescription = IntentDescription("Quickly log your mood for the day")
    
    @Parameter(title: "Mood")
    var mood: MoodSelectionEntity
    
    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$mood) mood")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let moodType: MoodType
        
        switch mood.id {
        case "good":
            moodType = .good
        case "neutral":
            moodType = .neutral
        case "difficult":
            moodType = .difficult
        default:
            moodType = .neutral
        }
        
        // Fetch health metrics
        let healthManager = HealthKitManager.shared
        let metrics = await healthManager.fetchTodayMetrics()
        
        // Generate contextual message
        let message = InsightsEngine.shared.generateContextualMessage(
            mood: moodType,
            hrvValue: metrics.hrv,
            activityCompletion: metrics.activity
        )
        
        // Save entry
        _ = PersistenceController.shared.createMoodEntry(
            mood: moodType,
            contextualMessage: message,
            hrvValue: metrics.hrv,
            activityRingCompletion: metrics.activity
        )
        
        return .result(dialog: IntentDialog("Mood logged as \(moodType.localizedLabel)"))
    }
}

struct MoodSelectionEntity: AppEntity {
    let id: String
    let name: String
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Mood"
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
    
    static var defaultQuery = MoodSelectionEntityQuery()
}

struct MoodSelectionEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [MoodSelectionEntity] {
        return identifiers.compactMap { id in
            switch id {
            case "good":
                return MoodSelectionEntity(id: "good", name: MoodType.good.localizedLabel)
            case "neutral":
                return MoodSelectionEntity(id: "neutral", name: MoodType.neutral.localizedLabel)
            case "difficult":
                return MoodSelectionEntity(id: "difficult", name: MoodType.difficult.localizedLabel)
            default:
                return nil
            }
        }
    }
    
    func suggestedEntities() async throws -> [MoodSelectionEntity] {
        return [
            MoodSelectionEntity(id: "good", name: MoodType.good.localizedLabel),
            MoodSelectionEntity(id: "neutral", name: MoodType.neutral.localizedLabel),
            MoodSelectionEntity(id: "difficult", name: MoodType.difficult.localizedLabel)
        ]
    }
    
    func defaultResult() async -> MoodSelectionEntity? {
        return MoodSelectionEntity(id: "neutral", name: MoodType.neutral.localizedLabel)
    }
}

// MARK: - View Trends Intent

struct ViewTrendsIntent: AppIntent {
    static var title: LocalizedStringResource = "View Mood Trends"
    static var description: IntentDescription = IntentDescription("See your recent mood history")
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        // This will open the app to the trends view
        return .result()
    }
}

// MARK: - App Shortcuts Provider

struct DayCloseShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: QuickMoodEntryIntent(),
            phrases: [
                "Log my mood in \(.applicationName)",
                "Record how I'm feeling in \(.applicationName)",
                "Check in with \(.applicationName)"
            ],
            shortTitle: "Log Mood",
            systemImageName: "face.smiling"
        )
        
        AppShortcut(
            intent: ViewTrendsIntent(),
            phrases: [
                "Show my mood trends in \(.applicationName)",
                "View my history in \(.applicationName)"
            ],
            shortTitle: "View Trends",
            systemImageName: "chart.line.uptrend.xyaxis"
        )
    }
}
