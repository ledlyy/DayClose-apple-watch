//
//  DayCloseTests.swift
//  DayClose Watch App Tests
//
//  Unit tests for core functionality
//

import XCTest
import CoreData
@testable import DayClose_Watch_App

final class PersistenceTests: XCTestCase {
    var persistenceController: PersistenceController!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
    }
    
    override func tearDown() {
        persistenceController = nil
        super.tearDown()
    }
    
    func testCreateMoodEntry() {
        let entry = persistenceController.createMoodEntry(
            mood: .good,
            note: "Test note",
            contextualMessage: "Test message",
            hrvValue: 50.0,
            activityRingCompletion: 0.8
        )
        
        XCTAssertNotNil(entry.id)
        XCTAssertEqual(entry.mood, .good)
        XCTAssertEqual(entry.note, "Test note")
        XCTAssertEqual(entry.contextualMessage, "Test message")
        XCTAssertEqual(entry.hrvValue, 50.0)
        XCTAssertEqual(entry.activityRingCompletion, 0.8)
        XCTAssertTrue(entry.isToday)
    }
    
    func testFetchTodayEntry() {
        // Create entry for today
        _ = persistenceController.createMoodEntry(mood: .neutral)
        
        // Fetch today's entry
        let todayEntry = persistenceController.fetchTodayEntry()
        
        XCTAssertNotNil(todayEntry)
        XCTAssertEqual(todayEntry?.mood, .neutral)
        XCTAssertTrue(todayEntry?.isToday ?? false)
    }
    
    func testFetchRecentEntries() {
        // Create multiple entries
        for i in 0..<5 {
            let entry = persistenceController.createMoodEntry(mood: .good)
            // Manually adjust date for testing
            entry.date = Calendar.current.date(byAdding: .day, value: -i, to: Date())
        }
        
        let entries = persistenceController.fetchRecentEntries(limit: 7)
        
        XCTAssertEqual(entries.count, 5)
        // Verify they're sorted by date (most recent first)
        XCTAssertTrue(entries[0].date ?? Date() >= entries[1].date ?? Date())
    }
    
    func testMoodDistribution() {
        // Create entries with different moods
        _ = persistenceController.createMoodEntry(mood: .good)
        _ = persistenceController.createMoodEntry(mood: .good)
        _ = persistenceController.createMoodEntry(mood: .neutral)
        _ = persistenceController.createMoodEntry(mood: .difficult)
        
        let distribution = persistenceController.getMoodDistribution(days: 7)
        
        XCTAssertEqual(distribution[.good], 2)
        XCTAssertEqual(distribution[.neutral], 1)
        XCTAssertEqual(distribution[.difficult], 1)
    }
    
    func testDeleteEntry() {
        let entry = persistenceController.createMoodEntry(mood: .good)
        let entryId = entry.id
        
        persistenceController.deleteEntry(entry)
        
        let fetchedEntry = persistenceController.fetchTodayEntry()
        XCTAssertNil(fetchedEntry)
    }
}

final class InsightsEngineTests: XCTestCase {
    let engine = InsightsEngine.shared
    
    func testGenerateContextualMessage() {
        let message = engine.generateContextualMessage(
            mood: .good,
            hrvValue: 60.0,
            activityCompletion: 0.9
        )
        
        XCTAssertFalse(message.isEmpty)
        XCTAssertTrue(message.count > 10) // Should be a reasonable message
    }
    
    func testGenerateContextualMessageAllMoods() {
        for mood in MoodType.allCases {
            let message = engine.generateContextualMessage(
                mood: mood,
                hrvValue: 50.0,
                activityCompletion: 0.5
            )
            
            XCTAssertFalse(message.isEmpty, "Message should not be empty for mood: \(mood)")
        }
    }
    
    func testTrendAnalysisImproving() {
        let context = PersistenceController(inMemory: true).container.viewContext
        var entries: [MoodEntry] = []
        
        // Create improving trend: difficult -> neutral -> good
        for (index, mood) in [MoodType.difficult, .difficult, .neutral, .neutral, .good, .good, .good].enumerated() {
            let entry = MoodEntry(context: context)
            entry.id = UUID()
            entry.date = Calendar.current.date(byAdding: .day, value: -index, to: Date())
            entry.moodRawValue = mood.rawValue
            entries.insert(entry, at: 0)
        }
        
        let analysis = engine.analyzeTrend(entries: entries)
        
        XCTAssertEqual(analysis.trend, .improving)
        XCTAssertFalse(analysis.message.isEmpty)
    }
    
    func testTrendAnalysisStable() {
        let context = PersistenceController(inMemory: true).container.viewContext
        var entries: [MoodEntry] = []
        
        // Create stable trend: all neutral
        for index in 0..<7 {
            let entry = MoodEntry(context: context)
            entry.id = UUID()
            entry.date = Calendar.current.date(byAdding: .day, value: -index, to: Date())
            entry.moodRawValue = MoodType.neutral.rawValue
            entries.insert(entry, at: 0)
        }
        
        let analysis = engine.analyzeTrend(entries: entries)
        
        XCTAssertEqual(analysis.trend, .stable)
    }
    
    func testTrendAnalysisInsufficientData() {
        let analysis = engine.analyzeTrend(entries: [])
        
        XCTAssertEqual(analysis.trend, .stable)
        XCTAssertFalse(analysis.message.isEmpty)
    }
}

final class MoodTypeTests: XCTestCase {
    func testMoodTypeEmojis() {
        XCTAssertEqual(MoodType.good.emoji, "😊")
        XCTAssertEqual(MoodType.neutral.emoji, "😐")
        XCTAssertEqual(MoodType.difficult.emoji, "😔")
    }
    
    func testMoodTypeLabels() {
        XCTAssertFalse(MoodType.good.labelEnglish.isEmpty)
        XCTAssertFalse(MoodType.good.labelTurkish.isEmpty)
        XCTAssertFalse(MoodType.neutral.localizedLabel.isEmpty)
    }
    
    func testMoodTypeColors() {
        XCTAssertEqual(MoodType.good.colorName, "MoodGreen")
        XCTAssertEqual(MoodType.neutral.colorName, "MoodYellow")
        XCTAssertEqual(MoodType.difficult.colorName, "MoodRed")
    }
    
    func testMoodTypeAccessibility() {
        for mood in MoodType.allCases {
            XCTAssertFalse(mood.accessibilityLabel.isEmpty)
            XCTAssertTrue(mood.accessibilityLabel.contains(mood.emoji))
        }
    }
}

final class UserPreferencesTests: XCTestCase {
    func testDefaultValues() {
        let prefs = UserPreferences.shared
        
        XCTAssertTrue(prefs.reminderEnabled)
        XCTAssertEqual(prefs.reminderHour, 20)
        XCTAssertEqual(prefs.reminderMinute, 0)
    }
    
    func testSetReminderTime() {
        let prefs = UserPreferences.shared
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = 19
        components.minute = 30
        let newTime = calendar.date(from: components)!
        
        prefs.setReminderTime(newTime)
        
        XCTAssertEqual(prefs.reminderHour, 19)
        XCTAssertEqual(prefs.reminderMinute, 30)
        XCTAssertFalse(prefs.hasScheduledReminder) // Should trigger rescheduling
    }
}

final class DiagnosticsLoggerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        DiagnosticsLogger.shared.clear()
    }
    
    func testLogPersistenceAndExport() {
        DiagnosticsLogger.shared.log(level: .info, message: "Test event", metadata: ["source": "unit-test"])
        
        let expectation = expectation(description: "Wait for log persistence")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        let events = DiagnosticsLogger.shared.recentEvents(limit: 10)
        XCTAssertFalse(events.isEmpty)
        XCTAssertEqual(events.first?.message, "Test event")
        
        let exportURL = DiagnosticsLogger.shared.export(forUserIdentifier: "test-user")
        XCTAssertNotNil(exportURL)
        
        if let url = exportURL {
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            try? FileManager.default.removeItem(at: url)
        }
    }
}
