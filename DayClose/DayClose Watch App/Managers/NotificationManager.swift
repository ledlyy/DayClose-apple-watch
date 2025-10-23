//
//  NotificationManager.swift
//  DayClose Watch App
//
//  Manages evening reminder notifications
//

import Foundation
import UserNotifications
import Combine

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let reminderIdentifier = "com.dayclose.evening.reminder"
    
    override private init() {
        super.init()
        notificationCenter.delegate = self
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                self?.checkAuthorizationStatus()
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    // MARK: - Scheduling
    
    func scheduleEveningReminder() {
        // Remove existing reminders
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
        
        let preferences = UserPreferences.shared
        guard preferences.reminderEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification.title", comment: "")
        content.body = NSLocalizedString("notification.body", comment: "")
        content.sound = .default
        content.categoryIdentifier = "MOOD_CHECK_IN"
        
        // Schedule for configured time
        var dateComponents = DateComponents()
        dateComponents.hour = preferences.reminderHour
        dateComponents.minute = preferences.reminderMinute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
                DiagnosticsLogger.shared.log(
                    level: .error,
                    message: "Notification scheduling failed",
                    metadata: ["error": error.localizedDescription]
                )
            } else {
                print("Evening reminder scheduled for \(preferences.reminderHour):\(String(format: "%02d", preferences.reminderMinute))")
                DiagnosticsLogger.shared.log(
                    level: .info,
                    message: "Evening reminder scheduled",
                    metadata: [
                        "hour": "\(preferences.reminderHour)",
                        "minute": String(format: "%02d", preferences.reminderMinute)
                    ]
                )
            }
        }
    }
    
    func cancelEveningReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
        UserPreferences.shared.hasScheduledReminder = false
        DiagnosticsLogger.shared.log(level: .info, message: "Evening reminder cancelled by user")
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap - app will open to main view
        completionHandler()
    }
}
