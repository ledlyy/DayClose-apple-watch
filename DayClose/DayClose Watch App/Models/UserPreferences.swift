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
    @AppStorage("reminderHour") var reminderHour: Int = 20  // 8 PM default
    @AppStorage("reminderMinute") var reminderMinute: Int = 0
    @AppStorage("hasScheduledReminder") var hasScheduledReminder: Bool = false
    @AppStorage("healthKitEnabled") var healthKitEnabled: Bool = false
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("preferredLanguage") var preferredLanguage: String = "en"
    @AppStorage("diagnosticsConsent") var diagnosticsConsent: Bool = false
    @AppStorage("diagnosticsUserIdentifier") var diagnosticsUserIdentifier: String = UUID()
        .uuidString

    // Streak tracking
    @AppStorage("currentStreak") var currentStreak: Int = 0
    @AppStorage("longestStreak") var longestStreak: Int = 0
    @AppStorage("lastCheckInDate") var lastCheckInDate: String = ""

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
        hasScheduledReminder = false  // Trigger rescheduling

        DiagnosticsLogger.shared.log(
            level: .info,
            message: "Reminder time updated",
            metadata: [
                "hour": "\(reminderHour)",
                "minute": String(format: "%02d", reminderMinute),
            ]
        )
    }

    /// Update streak when a new mood entry is logged
    func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        if let lastDate = formatter.date(from: lastCheckInDate) {
            let lastCheckIn = Calendar.current.startOfDay(for: lastDate)
            let daysBetween =
                Calendar.current.dateComponents([.day], from: lastCheckIn, to: today).day ?? 0

            if daysBetween == 1 {
                // Consecutive day - increment streak
                currentStreak += 1
                if currentStreak > longestStreak {
                    longestStreak = currentStreak
                }
            } else if daysBetween > 1 {
                // Streak broken - reset
                currentStreak = 1
            }
            // If daysBetween == 0, same day check-in, don't change streak
        } else {
            // First ever check-in
            currentStreak = 1
            longestStreak = 1
        }

        lastCheckInDate = formatter.string(from: today)

        DiagnosticsLogger.shared.log(
            level: .info,
            message: "Streak updated",
            metadata: [
                "currentStreak": "\(currentStreak)",
                "longestStreak": "\(longestStreak)",
            ]
        )
    }
}
