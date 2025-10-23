//
//  SettingsView.swift
//  DayClose Watch App
//
//  App settings and preferences
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var healthKitManager: HealthKitManager
    @StateObject private var preferences = UserPreferences.shared
    
    @State private var showingTimePicker = false
    @State private var showingProblemReport = false
    
    var body: some View {
        List {
            // Reminder settings
            Section {
                Toggle(isOn: $preferences.reminderEnabled) {
                    Label(NSLocalizedString("settings.reminder.toggle", comment: ""), systemImage: "bell.fill")
                }
                .onChange(of: preferences.reminderEnabled) { _, newValue in
                    DiagnosticsLogger.shared.log(
                        level: .info,
                        message: "Reminder preference changed",
                        metadata: ["enabled": newValue ? "true" : "false"]
                    )
                    if newValue {
                        notificationManager.scheduleEveningReminder()
                    } else {
                        notificationManager.cancelEveningReminder()
                    }
                }
                
                if preferences.reminderEnabled {
                    Button {
                        showingTimePicker = true
                    } label: {
                        HStack {
                            Text(NSLocalizedString("settings.reminder.time", comment: ""))
                            Spacer()
                            Text(formattedReminderTime)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text(NSLocalizedString("settings.section.reminders", comment: ""))
            }
            
            // HealthKit settings
            Section {
                Toggle(isOn: $preferences.healthKitEnabled) {
                    Label(NSLocalizedString("settings.health.toggle", comment: ""), systemImage: "heart.fill")
                }
                .onChange(of: preferences.healthKitEnabled) { _, newValue in
                    DiagnosticsLogger.shared.log(
                        level: .info,
                        message: "HealthKit preference changed",
                        metadata: ["enabled": newValue ? "true" : "false"]
                    )
                    if newValue && !healthKitManager.isAuthorized {
                        healthKitManager.requestAuthorization()
                    }
                }
                
                if preferences.healthKitEnabled {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(NSLocalizedString("settings.health.description", comment: ""))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text(NSLocalizedString("settings.section.health", comment: ""))
            }
            
            // Privacy section
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label(NSLocalizedString("settings.privacy.title", comment: ""), systemImage: "lock.shield.fill")
                        .font(.headline)
                    
                    Text(NSLocalizedString("settings.privacy.description", comment: ""))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text(NSLocalizedString("settings.section.privacy", comment: ""))
            }
            
            // About section
            Section {
                HStack {
                    Text(NSLocalizedString("settings.about.version", comment: ""))
                    Spacer()
                    Text(appVersion)
                        .foregroundStyle(.secondary)
                }
                
                NavigationLink {
                    AccessibilityInfoView()
                } label: {
                    Label(NSLocalizedString("settings.about.accessibility", comment: ""), systemImage: "accessibility")
                }
            } header: {
                Text(NSLocalizedString("settings.section.about", comment: ""))
            }
            
            // Support and diagnostics
            Section {
                Toggle(isOn: $preferences.diagnosticsConsent) {
                    Label(NSLocalizedString("settings.support.diagnostics.toggle", comment: ""), systemImage: "lock.doc")
                }
                .onChange(of: preferences.diagnosticsConsent) { _, newValue in
                    DiagnosticsLogger.shared.log(
                        level: .info,
                        message: "Diagnostics consent updated",
                        metadata: ["consent": newValue ? "enabled" : "disabled"]
                    )
                }
                
                if preferences.diagnosticsConsent {
                    Text(NSLocalizedString("settings.support.diagnostics.description", comment: ""))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Button {
                    DiagnosticsLogger.shared.log(level: .info, message: "Problem report flow started")
                    showingProblemReport = true
                } label: {
                    Label(NSLocalizedString("settings.support.report.button", comment: ""), systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
            } header: {
                Text(NSLocalizedString("settings.section.support", comment: ""))
            }
        }
        .navigationTitle(NSLocalizedString("settings.title", comment: ""))
        .sheet(isPresented: $showingTimePicker) {
            TimePickerView(selectedTime: $preferences.reminderTime, isPresented: $showingTimePicker)
        }
        .sheet(isPresented: $showingProblemReport) {
            ProblemReportView()
        }
    }
    
    private var formattedReminderTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: preferences.reminderTime)
    }
    
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
}

struct TimePickerView: View {
    @Binding var selectedTime: Date
    @Binding var isPresented: Bool
    
    @State private var tempTime: Date
    
    init(selectedTime: Binding<Date>, isPresented: Binding<Bool>) {
        self._selectedTime = selectedTime
        self._isPresented = isPresented
        self._tempTime = State(initialValue: selectedTime.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    NSLocalizedString("settings.time.picker.label", comment: ""),
                    selection: $tempTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
            }
            .navigationTitle(NSLocalizedString("settings.time.picker.title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("common.save", comment: "")) {
                        UserPreferences.shared.setReminderTime(tempTime)
                        NotificationManager.shared.scheduleEveningReminder()
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "")) {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct AccessibilityInfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(NSLocalizedString("accessibility.info.title", comment: ""))
                    .font(.headline)
                
                GestureInfoCard(
                    icon: "hand.tap.fill",
                    title: NSLocalizedString("accessibility.gesture.doubletap.title", comment: ""),
                    description: NSLocalizedString("accessibility.gesture.doubletap.description", comment: "")
                )
                
                GestureInfoCard(
                    icon: "arrow.up.and.down.circle.fill",
                    title: NSLocalizedString("accessibility.gesture.crown.title", comment: ""),
                    description: NSLocalizedString("accessibility.gesture.crown.description", comment: "")
                )
                
                GestureInfoCard(
                    icon: "hand.pinch.fill",
                    title: NSLocalizedString("accessibility.gesture.pinch.title", comment: ""),
                    description: NSLocalizedString("accessibility.gesture.pinch.description", comment: "")
                )
                
                GestureInfoCard(
                    icon: "speaker.wave.3.fill",
                    title: NSLocalizedString("accessibility.voiceover.title", comment: ""),
                    description: NSLocalizedString("accessibility.voiceover.description", comment: "")
                )
            }
            .padding()
        }
        .navigationTitle(NSLocalizedString("accessibility.title", comment: ""))
    }
}

struct GestureInfoCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(NotificationManager.shared)
            .environmentObject(HealthKitManager.shared)
    }
}
