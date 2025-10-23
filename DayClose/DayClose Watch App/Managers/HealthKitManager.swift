//
//  HealthKitManager.swift
//  DayClose Watch App
//
//  Privacy-preserving HealthKit integration (read-only, on-device)
//

import Foundation
import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    @Published var hrvValue: Double?
    @Published var activityRingCompletion: Double?
    
    private let typesToRead: Set<HKObjectType> = {
        var types = Set<HKObjectType>()
        
        // Heart Rate Variability
        if let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) {
            types.insert(hrvType)
        }
        
        // Activity Summary
        types.insert(HKObjectType.activitySummaryType())
        
        return types
    }()
    
    private init() {}
    
    // MARK: - Authorization
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit not available on this device")
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                if let error = error {
                    print("HealthKit authorization error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Data Fetching (Privacy-preserving)
    
    func fetchTodayMetrics() async -> (hrv: Double?, activityCompletion: Double?) {
        guard isAuthorized else {
            return (nil, nil)
        }
        
        async let hrv = fetchLatestHRV()
        async let activity = fetchTodayActivityCompletion()
        
        return await (hrv, activity)
    }
    
    private func fetchLatestHRV() async -> Double? {
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            return nil
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: hrvType,
            predicate: todayPredicate(),
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            if let error = error {
                print("HRV fetch error: \(error.localizedDescription)")
            }
        }
        
        return await withCheckedContinuation { continuation in
            let modifiedQuery = HKSampleQuery(
                sampleType: hrvType,
                predicate: todayPredicate(),
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, _ in
                if let sample = samples?.first as? HKQuantitySample {
                    let value = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
                    continuation.resume(returning: value)
                } else {
                    continuation.resume(returning: nil)
                }
            }
            healthStore.execute(modifiedQuery)
        }
    }
    
    private func fetchTodayActivityCompletion() async -> Double? {
        let calendar = Calendar.current
        let now = Date()
        
        guard let startOfDay = calendar.dateInterval(of: .day, for: now)?.start else {
            return nil
        }
        
        let predicate = HKQuery.predicate(forActivitySummary: with: calendar.dateComponents([.year, .month, .day], from: startOfDay))
        
        return await withCheckedContinuation { continuation in
            let query = HKActivitySummaryQuery(predicate: predicate) { _, summaries, _ in
                guard let summary = summaries?.first else {
                    continuation.resume(returning: nil)
                    return
                }
                
                // Calculate average completion of three rings
                let moveCompletion = summary.activeEnergyBurnedGoal.doubleValue(for: .kilocalorie()) > 0
                    ? summary.activeEnergyBurned.doubleValue(for: .kilocalorie()) / summary.activeEnergyBurnedGoal.doubleValue(for: .kilocalorie())
                    : 0
                
                let exerciseCompletion = summary.appleExerciseTimeGoal.doubleValue(for: .minute()) > 0
                    ? summary.appleExerciseTime.doubleValue(for: .minute()) / summary.appleExerciseTimeGoal.doubleValue(for: .minute())
                    : 0
                
                let standCompletion = summary.appleStandHoursGoal.doubleValue(for: .count()) > 0
                    ? summary.appleStandHours.doubleValue(for: .count()) / summary.appleStandHoursGoal.doubleValue(for: .count())
                    : 0
                
                let avgCompletion = (moveCompletion + exerciseCompletion + standCompletion) / 3.0
                continuation.resume(returning: min(avgCompletion, 1.0))
            }
            
            healthStore.execute(query)
        }
    }
    
    private func todayPredicate() -> NSPredicate {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
    }
}
