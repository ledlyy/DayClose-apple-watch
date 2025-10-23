//
//  InsightsEngine.swift
//  DayClose Watch App
//
//  On-device contextual message generation using deterministic rules
//  Can be replaced with CoreML model for more sophisticated inference
//

import Foundation

class InsightsEngine {
    static let shared = InsightsEngine()
    
    private init() {}
    
    // MARK: - Contextual Message Generation
    
    func generateContextualMessage(
        mood: MoodType,
        hrvValue: Double?,
        activityCompletion: Double?
    ) -> String {
        // Deterministic rule-based system
        // In production, this could be replaced with a CoreML model
        
        let messages = getMessagesForMood(mood, hrv: hrvValue, activity: activityCompletion)
        return messages.randomElement() ?? getDefaultMessage(for: mood)
    }
    
    private func getMessagesForMood(
        _ mood: MoodType,
        hrv: Double?,
        activity: Double?
    ) -> [String] {
        let highActivity = (activity ?? 0) > 0.7
        let lowActivity = (activity ?? 0) < 0.3
        let goodHRV = (hrvValue ?? 0) > 50
        
        switch mood {
        case .good:
            if highActivity && goodHRV {
                return [
                    NSLocalizedString("insight.good.active.high", comment: ""),
                    NSLocalizedString("insight.good.balanced", comment: "")
                ]
            } else if highActivity {
                return [
                    NSLocalizedString("insight.good.active", comment: "")
                ]
            } else {
                return [
                    NSLocalizedString("insight.good.default", comment: ""),
                    NSLocalizedString("insight.good.grateful", comment: "")
                ]
            }
            
        case .neutral:
            if lowActivity {
                return [
                    NSLocalizedString("insight.neutral.inactive", comment: ""),
                    NSLocalizedString("insight.neutral.rest", comment: "")
                ]
            } else {
                return [
                    NSLocalizedString("insight.neutral.default", comment: ""),
                    NSLocalizedString("insight.neutral.steady", comment: "")
                ]
            }
            
        case .difficult:
            if lowActivity && !goodHRV {
                return [
                    NSLocalizedString("insight.difficult.rest.needed", comment: ""),
                    NSLocalizedString("insight.difficult.selfcare", comment: "")
                ]
            } else {
                return [
                    NSLocalizedString("insight.difficult.default", comment: ""),
                    NSLocalizedString("insight.difficult.tomorrow", comment: "")
                ]
            }
        }
    }
    
    private func getDefaultMessage(for mood: MoodType) -> String {
        switch mood {
        case .good:
            return NSLocalizedString("insight.good.default", comment: "")
        case .neutral:
            return NSLocalizedString("insight.neutral.default", comment: "")
        case .difficult:
            return NSLocalizedString("insight.difficult.default", comment: "")
        }
    }
    
    // MARK: - Trend Analysis
    
    func analyzeTrend(entries: [MoodEntry]) -> TrendAnalysis {
        guard entries.count >= 3 else {
            return TrendAnalysis(trend: .stable, message: NSLocalizedString("trend.insufficient.data", comment: ""))
        }
        
        let moodScores = entries.prefix(7).compactMap { entry -> Int? in
            switch entry.mood {
            case .good: return 2
            case .neutral: return 1
            case .difficult: return 0
            case .none: return nil
            }
        }
        
        guard moodScores.count >= 3 else {
            return TrendAnalysis(trend: .stable, message: NSLocalizedString("trend.insufficient.data", comment: ""))
        }
        
        let recentAvg = Double(moodScores.prefix(3).reduce(0, +)) / 3.0
        let olderAvg = Double(moodScores.suffix(from: 3).reduce(0, +)) / Double(moodScores.count - 3)
        
        if recentAvg > olderAvg + 0.5 {
            return TrendAnalysis(trend: .improving, message: NSLocalizedString("trend.improving", comment: ""))
        } else if recentAvg < olderAvg - 0.5 {
            return TrendAnalysis(trend: .declining, message: NSLocalizedString("trend.declining", comment: ""))
        } else {
            return TrendAnalysis(trend: .stable, message: NSLocalizedString("trend.stable", comment: ""))
        }
    }
}

// MARK: - Supporting Types

struct TrendAnalysis {
    enum Trend {
        case improving
        case stable
        case declining
    }
    
    let trend: Trend
    let message: String
}
