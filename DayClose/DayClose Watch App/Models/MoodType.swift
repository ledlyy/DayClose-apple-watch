//
//  MoodType.swift
//  DayClose Watch App
//
//  Core mood type enum with Turkish and English labels
//

import Foundation

enum MoodType: String, CaseIterable, Codable {
    case good = "good"
    case neutral = "neutral"
    case difficult = "difficult"
    
    var emoji: String {
        switch self {
        case .good: return "😊"
        case .neutral: return "😐"
        case .difficult: return "😔"
        }
    }
    
    var labelTurkish: String {
        switch self {
        case .good: return "İyi"
        case .neutral: return "Normal"
        case .difficult: return "Zor"
        }
    }
    
    var labelEnglish: String {
        switch self {
        case .good: return "Good"
        case .neutral: return "Neutral"
        case .difficult: return "Difficult"
        }
    }
    
    var localizedLabel: String {
        if Locale.current.language.languageCode?.identifier == "tr" {
            return labelTurkish
        }
        return labelEnglish
    }
    
    var accessibilityLabel: String {
        String(format: NSLocalizedString("mood.accessibility.label", comment: ""), localizedLabel, emoji)
    }
    
    var colorName: String {
        switch self {
        case .good: return "MoodGreen"
        case .neutral: return "MoodYellow"
        case .difficult: return "MoodRed"
        }
    }
}
