//
//  MoodType.swift
//  DayClose Watch App
//
//  Core mood type enum with Turkish and English labels
//

import Foundation

enum MoodType: String, CaseIterable, Codable {
    case great = "great"
    case good = "good"
    case neutral = "neutral"
    case difficult = "difficult"
    case bad = "bad"

    var emoji: String {
        switch self {
        case .great: return "🤩"
        case .good: return "😊"
        case .neutral: return "😐"
        case .difficult: return "😔"
        case .bad: return "😢"
        }
    }

    var labelTurkish: String {
        switch self {
        case .great: return "Harika"
        case .good: return "İyi"
        case .neutral: return "Normal"
        case .difficult: return "Zor"
        case .bad: return "Kötü"
        }
    }

    var labelEnglish: String {
        switch self {
        case .great: return "Great"
        case .good: return "Good"
        case .neutral: return "Neutral"
        case .difficult: return "Difficult"
        case .bad: return "Bad"
        }
    }

    /// Numeric score for trend analysis (1-5 scale)
    var score: Int {
        switch self {
        case .great: return 5
        case .good: return 4
        case .neutral: return 3
        case .difficult: return 2
        case .bad: return 1
        }
    }

    var localizedLabel: String {
        if Locale.current.language.languageCode?.identifier == "tr" {
            return labelTurkish
        }
        return labelEnglish
    }

    var accessibilityLabel: String {
        String(
            format: NSLocalizedString("mood.accessibility.label", comment: ""), localizedLabel,
            emoji)
    }

    var colorName: String {
        switch self {
        case .great: return "MoodGreen"
        case .good: return "MoodGreen"
        case .neutral: return "MoodYellow"
        case .difficult: return "MoodRed"
        case .bad: return "MoodRed"
        }
    }

    /// Color gradient for visual feedback
    var gradientColors: (start: String, end: String) {
        switch self {
        case .great: return ("#4ade80", "#22c55e")
        case .good: return ("#86efac", "#4ade80")
        case .neutral: return ("#fde047", "#facc15")
        case .difficult: return ("#fb923c", "#f97316")
        case .bad: return ("#ef4444", "#dc2626")
        }
    }
}
