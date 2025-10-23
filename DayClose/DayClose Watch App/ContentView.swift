//
//  ContentView.swift
//  DayClose Watch App
//
//  Main navigation hub for the app
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var healthKitManager: HealthKitManager

    @State private var showingMoodSelection = false
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Main mood entry view
            MoodPromptView(showingMoodSelection: $showingMoodSelection)
                .tag(0)

            // Trends/history view
            TrendView()
                .tag(1)

            // Settings view
            SettingsView()
                .tag(2)
        }
        .tabViewStyle(.verticalPage)
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
        .sheet(isPresented: $showingMoodSelection) {
            MoodSelectionView(isPresented: $showingMoodSelection)
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(HealthKitManager.shared)
        .environmentObject(NotificationManager.shared)
}
