//
//  DayCloseApp.swift
//  DayClose Watch App
//
//  Created by DayClose Team on October 13, 2025.
//

import SwiftUI
import UserNotifications

@main
struct DayCloseApp: App {
    @WKExtensionDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var persistenceController = PersistenceController.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var healthKitManager = HealthKitManager.shared
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(notificationManager)
                .environmentObject(healthKitManager)
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        DiagnosticsLogger.shared.log(level: .info, message: "App setup started")
        
        // Request notification permissions
        notificationManager.requestAuthorization()
        DiagnosticsLogger.shared.log(level: .info, message: "Notification authorization requested")
        
        // Request HealthKit permissions (user can deny)
        healthKitManager.requestAuthorization()
        DiagnosticsLogger.shared.log(level: .info, message: "HealthKit authorization requested")
        
        // Schedule evening reminder if not already set
        if UserPreferences.shared.reminderEnabled && !UserPreferences.shared.hasScheduledReminder {
            notificationManager.scheduleEveningReminder()
            UserPreferences.shared.hasScheduledReminder = true
            DiagnosticsLogger.shared.log(level: .info, message: "Evening reminder scheduled on startup")
        }
    }
}

class AppDelegate: NSObject, WKExtensionDelegate {
    func applicationDidFinishLaunching() {
        // App lifecycle setup
        print("DayClose launched - Privacy-first, on-device only")
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Schedule next background refresh if needed
                scheduleBackgroundRefresh()
                backgroundTask.setTaskCompletedWithSnapshot(false)
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    private func scheduleBackgroundRefresh() {
        let targetDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        WKExtension.shared().scheduleBackgroundRefresh(
            withPreferredDate: targetDate,
            userInfo: nil
        ) { error in
            if let error = error {
                print("Background refresh scheduling error: \(error.localizedDescription)")
            }
        }
    }
}
