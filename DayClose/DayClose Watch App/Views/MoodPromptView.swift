//
//  MoodPromptView.swift
//  DayClose Watch App
//
//  Main view showing evening prompt or today's status
//

import SwiftUI

struct MoodPromptView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var showingMoodSelection: Bool
    
    @State private var todayEntry: MoodEntry?
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let entry = todayEntry {
                    // Already checked in today
                    CompletedCheckInView(entry: entry)
                } else {
                    // Prompt to check in
                    PromptView(showingMoodSelection: $showingMoodSelection)
                }
            }
            .padding()
        }
        .navigationTitle("DayClose")
        .onAppear {
            loadTodayEntry()
        }
    }
    
    private func loadTodayEntry() {
        todayEntry = PersistenceController.shared.fetchTodayEntry()
    }
}

struct PromptView: View {
    @Binding var showingMoodSelection: Bool
    @StateObject private var preferences = UserPreferences.shared
    
    var body: some View {
        VStack(spacing: 16) {
            heroCard
            
            // Streak badge (if exists)
            if preferences.currentStreak > 0 {
                streakBadge
            }
            
            Button {
                WKInterfaceDevice.current().play(.click)
                showingMoodSelection = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles.rectangle.stack")
                        .font(.headline)
                        .symbolRenderingMode(.hierarchical)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(NSLocalizedString("prompt.button", comment: ""))
                            .font(.body.weight(.semibold))
                        Text(NSLocalizedString("prompt.button.detail", comment: ""))
                            .font(.caption2)
                            .foregroundStyle(Color.primary.opacity(0.7))
                    }
                    
                    Spacer(minLength: 0)
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.headline)
                        .symbolRenderingMode(.hierarchical)
                }
            }
            .buttonStyle(ReflectionPrimaryButtonStyle())
            .accessibilityLabel(NSLocalizedString("prompt.button.accessibility", comment: ""))
            
            // Gesture hint
            Text(NSLocalizedString("prompt.gesture.hint", comment: ""))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(greetingText.uppercased())
                .font(.caption2)
                .fontWeight(.semibold)
                .kerning(0.8)
                .foregroundStyle(Color.white.opacity(0.85))
            
            Text(NSLocalizedString("prompt.card.title", comment: ""))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.white)
            
            Text(NSLocalizedString("prompt.card.subtitle", comment: ""))
                .font(.footnote)
                .foregroundStyle(Color.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 120, alignment: .topLeading)
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(accentGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .overlay(
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .blur(radius: 24)
                        .offset(x: 24, y: -36)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)
        }
        .overlay(alignment: .bottomTrailing) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(Color.white.opacity(0.7))
                .padding(14)
        }
    }
    
    private var streakBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
                .symbolEffect(.pulse, options: .repeating)
            
            Text("\(preferences.currentStreak)")
                .font(.title2.bold())
                .foregroundStyle(.orange)
            
            Text(preferences.currentStreak == 1 ? 
                 NSLocalizedString("streak.day.singular", comment: "") :
                 NSLocalizedString("streak.days.plural", comment: ""))
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if preferences.currentStreak == preferences.longestStreak && preferences.longestStreak > 1 {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.yellow)
                    .symbolEffect(.bounce, options: .repeating)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color(.systemGray6))
                .overlay(
                    Capsule()
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
        .transition(.scale.combined(with: .opacity))
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return NSLocalizedString("greeting.morning", comment: "")
        case 12..<17:
            return NSLocalizedString("greeting.afternoon", comment: "")
        case 17..<22:
            return NSLocalizedString("greeting.evening", comment: "")
        default:
            return NSLocalizedString("greeting.night", comment: "")
        }
    }
    
    private var accentGradient: LinearGradient {
        let hour = Calendar.current.component(.hour, from: Date())
        let colors: [Color]
        
        switch hour {
        case 5..<12:
            colors = [Color.cyan, Color.blue]
        case 12..<17:
            colors = [Color.orange, Color.pink]
        case 17..<22:
            colors = [Color.purple, Color.indigo]
        default:
            colors = [Color(red: 0.15, green: 0.18, blue: 0.32), Color.indigo]
        }
        
        return LinearGradient(colors: colors,
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing)
    }
}

struct CompletedCheckInView: View {
    let entry: MoodEntry
    
    var body: some View {
        VStack(spacing: 16) {
            // Checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.green)
                .accessibilityLabel(NSLocalizedString("checkin.complete.accessibility", comment: ""))
            
            // Mood display
            if let mood = entry.mood {
                HStack(spacing: 8) {
                    Text(mood.emoji)
                        .font(.largeTitle)
                    Text(mood.localizedLabel)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            
            // Contextual message
            if let message = entry.contextualMessage {
                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            
            // Timestamp
            Text(entry.formattedDate)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }
}

#Preview {
    MoodPromptView(showingMoodSelection: .constant(false))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

private struct ReflectionPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(buttonGradient(isPressed: configuration.isPressed))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            }
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.1 : 0.22),
                    radius: configuration.isPressed ? 2 : 6,
                    x: 0,
                    y: configuration.isPressed ? 1 : 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
    
    private func buttonGradient(isPressed: Bool) -> LinearGradient {
        let baseColors = [Color(red: 0.32, green: 0.38, blue: 0.94), Color.purple]
        let pressedColors = [Color(red: 0.26, green: 0.32, blue: 0.78), Color(red: 0.44, green: 0.24, blue: 0.78)]
        
        return LinearGradient(colors: isPressed ? pressedColors : baseColors,
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing)
    }
}
