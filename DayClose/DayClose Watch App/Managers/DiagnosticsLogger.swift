//
//  DiagnosticsLogger.swift
//  DayClose Watch App
//
//  Lightweight on-device diagnostics log with user-controlled export
//

import Foundation

/// Severity levels for diagnostic events.
enum DiagnosticsLogLevel: String, Codable {
    case info
    case warning
    case error
}

/// Single diagnostic event.
struct DiagnosticsLogEvent: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let level: DiagnosticsLogLevel
    let message: String
    let metadata: [String: String]?
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        level: DiagnosticsLogLevel,
        message: String,
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.level = level
        self.message = message
        self.metadata = metadata
    }
}

/// Handles persistence and export of diagnostics data. All logs stay on-device unless
/// the user explicitly exports them.
final class DiagnosticsLogger {
    static let shared = DiagnosticsLogger()
    
    private let queue = DispatchQueue(label: "com.dayclose.diagnostics.logger", qos: .utility)
    private let fileURL: URL
    private let exportDirectoryURL: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var events: [DiagnosticsLogEvent] = []
    private let maxEntries = 500
    
    private init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder.dateDecodingStrategy = .iso8601
        
        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let diagnosticsDirectory = supportDirectory.appendingPathComponent("Diagnostics", isDirectory: true)
        self.fileURL = diagnosticsDirectory.appendingPathComponent("logs.json")
        
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.exportDirectoryURL = cachesDirectory.appendingPathComponent("DiagnosticsExports", isDirectory: true)
        
        queue.sync {
            self.prepareDirectories(at: diagnosticsDirectory)
            self.prepareDirectories(at: self.exportDirectoryURL)
            self.loadEventsFromDisk()
        }
    }
    
    /// Records an event with optional metadata. Metadata values are truncated to 200 characters
    /// to reduce accidental leakage of large payloads.
    func log(
        level: DiagnosticsLogLevel,
        message: String,
        metadata: [String: String]? = nil
    ) {
        let sanitizedMetadata = metadata?.mapValues { value in
            if value.count > 200 {
                let index = value.index(value.startIndex, offsetBy: 200)
                return String(value[..<index])
            }
            return value
        }
        
        let event = DiagnosticsLogEvent(level: level, message: message, metadata: sanitizedMetadata)
        
        queue.async {
            self.events.append(event)
            if self.events.count > self.maxEntries {
                self.events.removeFirst(self.events.count - self.maxEntries)
            }
            self.persistEventsToDisk()
        }
    }
    
    /// Returns the most recent diagnostics events.
    func recentEvents(limit: Int = 100) -> [DiagnosticsLogEvent] {
        queue.sync {
            let slice = events.suffix(limit)
            return Array(slice)
        }
    }
    
    /// Removes all diagnostics data from disk.
    func clear() {
        queue.async {
            self.events.removeAll()
            try? self.fileManager.removeItem(at: self.fileURL)
        }
    }
    
    /// Creates a redacted export file. The caller is responsible for deleting the file after sharing.
    func export(forUserIdentifier userIdentifier: String) -> URL? {
        queue.sync {
            guard !events.isEmpty else { return nil }
            
            let exportFilename = "diagnostics-\(userIdentifier)-\(Int(Date().timeIntervalSince1970)).json"
            let exportURL = exportDirectoryURL.appendingPathComponent(exportFilename)
            
            do {
                let payload = ExportPayload(
                    generatedAt: Date(),
                    userIdentifier: userIdentifier,
                    events: events
                )
                let data = try encoder.encode(payload)
                try data.write(to: exportURL, options: [.atomic])
                try setCompleteFileProtection(at: exportURL)
                return exportURL
            } catch {
                print("Diagnostics export failed: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    // MARK: - Helpers
    
    private func prepareDirectories(at url: URL) {
        do {
            if !fileManager.fileExists(atPath: url.path) {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
            }
            try setCompleteFileProtection(at: url)
        } catch {
            print("Diagnostics directory setup failed: \(error.localizedDescription)")
        }
    }
    
    private func loadEventsFromDisk() {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            events = []
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            events = try decoder.decode([DiagnosticsLogEvent].self, from: data)
        } catch {
            print("Diagnostics load failed: \(error.localizedDescription)")
            events = []
        }
    }
    
    private func persistEventsToDisk() {
        do {
            let data = try encoder.encode(events)
            try data.write(to: fileURL, options: [.atomic])
            try setCompleteFileProtection(at: fileURL)
        } catch {
            print("Diagnostics persistence failed: \(error.localizedDescription)")
        }
    }
    
    private func setCompleteFileProtection(at url: URL) throws {
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try url.setResourceValues(resourceValues)
        
        let attributes: [FileAttributeKey: Any] = [.protectionKey: FileProtectionType.complete]
        try fileManager.setAttributes(attributes, ofItemAtPath: url.path)
    }
}

private struct ExportPayload: Codable {
    let generatedAt: Date
    let userIdentifier: String
    let events: [DiagnosticsLogEvent]
}
