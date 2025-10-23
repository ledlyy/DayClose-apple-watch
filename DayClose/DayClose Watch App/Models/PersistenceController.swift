//
//  PersistenceController.swift
//  DayClose Watch App
//
//  Core Data stack with NSPersistentStoreFileProtectionComplete
//

import CoreData
import Foundation

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    // Preview instance for SwiftUI previews and tests
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Create sample data
        for i in 0..<7 {
            let entry = MoodEntry(context: viewContext)
            entry.id = UUID()
            entry.date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            entry.moodRawValue = MoodType.allCases.randomElement()!.rawValue
            entry.contextualMessage = "Sample message \(i)"
            entry.hrvValue = Double.random(in: 30...80)
            entry.activityRingCompletion = Double.random(in: 0...1)
        }
        
        do {
            try viewContext.save()
        } catch {
            fatalError("Preview data creation failed: \(error)")
        }
        
        return controller
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DayClose")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Apply file protection for privacy
            if let description = container.persistentStoreDescriptions.first {
                description.setOption(
                    FileProtectionType.complete as NSObject,
                    forKey: NSPersistentStoreFileProtectionKey
                )
            }
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                // In production, handle this more gracefully
                fatalError("Core Data store failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - CRUD Operations
    
    func createMoodEntry(
        mood: MoodType,
        note: String? = nil,
        contextualMessage: String? = nil,
        hrvValue: Double? = nil,
        activityRingCompletion: Double? = nil
    ) -> MoodEntry {
        let context = container.viewContext
        let entry = MoodEntry(context: context)
        
        entry.id = UUID()
        entry.date = Date()
        entry.moodRawValue = mood.rawValue
        entry.note = note
        entry.contextualMessage = contextualMessage
        entry.hrvValue = hrvValue ?? 0
        entry.activityRingCompletion = activityRingCompletion ?? 0
        
        saveContext()
        return entry
    }
    
    func fetchRecentEntries(limit: Int = 7) -> [MoodEntry] {
        let request = MoodEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntry.date, ascending: false)]
        request.fetchLimit = limit
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Failed to fetch entries: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchTodayEntry() -> MoodEntry? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request = MoodEntry.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.fetchLimit = 1
        
        do {
            return try container.viewContext.fetch(request).first
        } catch {
            print("Failed to fetch today's entry: \(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteEntry(_ entry: MoodEntry) {
        container.viewContext.delete(entry)
        saveContext()
    }
    
    func saveContext() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Statistics
    
    func getMoodDistribution(days: Int = 7) -> [MoodType: Int] {
        let entries = fetchRecentEntries(limit: days)
        var distribution: [MoodType: Int] = [:]
        
        for entry in entries {
            if let mood = MoodType(rawValue: entry.moodRawValue ?? "") {
                distribution[mood, default: 0] += 1
            }
        }
        
        return distribution
    }
}

// MARK: - MoodEntry Extensions

extension MoodEntry {
    var mood: MoodType? {
        get {
            guard let rawValue = moodRawValue else { return nil }
            return MoodType(rawValue: rawValue)
        }
        set {
            moodRawValue = newValue?.rawValue
        }
    }
    
    var formattedDate: String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var isToday: Bool {
        guard let date = date else { return false }
        return Calendar.current.isDateInToday(date)
    }
}
