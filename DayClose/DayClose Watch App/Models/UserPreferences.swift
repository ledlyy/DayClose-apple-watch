//
//  UserPreferences.swift
//  DayClose Watch App
//
//  App-wide user preferences using AppStorage
//

import Foundation
import SwiftUI

class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    
    @AppStorage("reminderEnabled") var reminderEnabled: Bool = true
    @AppStorage("reminderHour") var reminderHour: Int = 20 // 8 PM default
    @AppStorage("reminderMinute") var reminderMinute: Int = 0
    @AppStorage("hasScheduledReminder") var hasScheduledReminder: Bool = false
    @AppStorage("healthKitEnabled") var healthKitEnabled: Bool = false
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("preferredLanguage") var preferredLanguage: String = "en"
    @AppStorage("diagnosticsConsent") var diagnosticsConsent: Bool = false
    @AppStorage("diagnosticsUserIdentifier") var diagnosticsUserIdentifier: String = UUID().uuidString
    
    private init() {}
    
    var reminderTime: Date {
        var components = DateComponents()
        components.hour = reminderHour
        components.minute = reminderMinute
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func setReminderTime(_ date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        reminderHour = components.hour ?? 20
        reminderMinute = components.minute ?? 0
        hasScheduledReminder = false // Trigger rescheduling
        
        DiagnosticsLogger.shared.log(
            level: .info,
            message: "Reminder time updated",
            metadata: [
                "hour": "\(reminderHour)",
                "minute": String(format: "%02d", reminderMinute)
            ]
        )
    }
}
