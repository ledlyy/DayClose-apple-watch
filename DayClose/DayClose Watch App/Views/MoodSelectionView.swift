//
//  MoodSelectionView.swift
//  DayClose Watch App
//
//  Mood selection interface with gesture support
//

import SwiftUI

struct MoodSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var healthKitManager: HealthKitManager
    
    @Binding var isPresented: Bool
    
    @State private var selectedMood: MoodType = .neutral
    @State private var isProcessing = false
    @State private var showingFeedback = false
    @State private var contextualMessage: String = ""
    @FocusState private var focusedMood: MoodType?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if !showingFeedback {
                    selectionView
                } else {
                    feedbackView
                }
            }
            .padding()
            .navigationTitle(NSLocalizedString("mood.selection.title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            focusedMood = selectedMood
        }
    }
    
    private var selectionView: some View {
        VStack(spacing: 24) {
            Text(NSLocalizedString("mood.selection.question", comment: ""))
                .font(.headline)
                .multilineTextAlignment(.center)
            
            // Mood options with focus support
            ForEach(MoodType.allCases, id: \.self) { mood in
                MoodButton(
                    mood: mood,
                    isSelected: selectedMood == mood,
                    isFocused: focusedMood == mood
                ) {
                    selectMood(mood)
                }
                .focused($focusedMood, equals: mood)
                .digitalCrownRotation(
                    $focusedMood,
                    from: MoodType.allCases.first!,
                    through: MoodType.allCases.last!,
                    by: 1,
                    sensitivity: .medium,
                    isContinuous: false,
                    isHapticFeedbackEnabled: true
                )
            }
            
            // Confirm button (for double-tap gesture)
            Button {
                confirmSelection()
            } label: {
                Label(NSLocalizedString("mood.selection.confirm", comment: ""), systemImage: "checkmark.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .disabled(isProcessing)
            .accessibilityHint(NSLocalizedString("mood.selection.confirm.hint", comment: ""))
            
            // Cancel button
            Button(NSLocalizedString("mood.selection.cancel", comment: "")) {
                dismiss()
            }
            .buttonStyle(.bordered)
            .disabled(isProcessing)
        }
    }
    
    private var feedbackView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: showingFeedback)
            
            Text(selectedMood.emoji)
                .font(.system(size: 60))
            
            Text(contextualMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Button(NSLocalizedString("mood.feedback.done", comment: "")) {
                isPresented = false
            }
            .buttonStyle(.borderedProminent)
        }
        .onAppear {
            WKInterfaceDevice.current().play(.success)
        }
    }
    
    private func selectMood(_ mood: MoodType) {
        selectedMood = mood
        focusedMood = mood
        WKInterfaceDevice.current().play(.click)
    }
    
    private func confirmSelection() {
        guard !isProcessing else { return }
        isProcessing = true
        
        Task {
            // Fetch health metrics
            let metrics = await healthKitManager.fetchTodayMetrics()
            
            // Generate contextual message
            let message = InsightsEngine.shared.generateContextualMessage(
                mood: selectedMood,
                hrvValue: metrics.hrv,
                activityCompletion: metrics.activity
            )
            
            // Save entry
            await MainActor.run {
                _ = PersistenceController.shared.createMoodEntry(
                    mood: selectedMood,
                    contextualMessage: message,
                    hrvValue: metrics.hrv,
                    activityRingCompletion: metrics.activity
                )
                
                DiagnosticsLogger.shared.log(
                    level: .info,
                    message: "Mood entry recorded",
                    metadata: [
                        "mood": selectedMood.rawValue,
                        "hasHRV": metrics.hrv == nil ? "false" : "true",
                        "hasActivity": metrics.activity == nil ? "false" : "true"
                    ]
                )
                
                contextualMessage = message
                isProcessing = false
                showingFeedback = true
            }
        }
    }
}

struct MoodButton: View {
    let mood: MoodType
    let isSelected: Bool
    let isFocused: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(mood.emoji)
                    .font(.largeTitle)
                
                Text(mood.localizedLabel)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isFocused ? 3 : 0)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mood.accessibilityLabel)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color(mood.colorName).opacity(0.3)
        }
        return Color(.systemGray6)
    }
    
    private var borderColor: Color {
        Color.accentColor
    }
}

#Preview {
    MoodSelectionView(isPresented: .constant(true))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(HealthKitManager.shared)
}
