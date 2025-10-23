//
//  ProblemReportView.swift
//  DayClose Watch App
//
//  Allows users to review and export diagnostics only when they consent.
//

import SwiftUI

struct ProblemReportView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var preferences = UserPreferences.shared
    
    @State private var recentEvents: [DiagnosticsLogEvent] = []
    @State private var exportURL: URL?
    @State private var isGeneratingExport = false
    @State private var showGenerationError = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(NSLocalizedString("problem.report.description", comment: ""))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    if preferences.diagnosticsConsent {
                        exportControls
                    } else {
                        Text(NSLocalizedString("problem.report.noConsent", comment: ""))
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section {
                    if recentEvents.isEmpty {
                        Text(NSLocalizedString("problem.report.empty", comment: ""))
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(recentEvents) { event in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.message)
                                    .font(.subheadline)
                                HStack {
                                    Text(formattedTimestamp(for: event.timestamp))
                                    Spacer()
                                    Text(event.level.rawValue.uppercased())
                                }
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Text(NSLocalizedString("problem.report.recentEvents", comment: ""))
                }
            }
            .navigationTitle(NSLocalizedString("problem.report.title", comment: ""))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.close", comment: "")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        reloadEvents()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel(NSLocalizedString("problem.report.refresh", comment: ""))
                }
            }
            .alert(
                NSLocalizedString("problem.report.error.title", comment: ""),
                isPresented: $showGenerationError
            ) {
                Button(NSLocalizedString("common.ok", comment: ""), role: .cancel) {}
            } message: {
                Text(NSLocalizedString("problem.report.error.message", comment: ""))
            }
            .onAppear {
                reloadEvents()
            }
        }
    }
    
    private var exportControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                generateExport()
            } label: {
                if isGeneratingExport {
                    ProgressView()
                } else {
                    Label(NSLocalizedString("problem.report.generate", comment: ""), systemImage: "doc.badge.plus")
                }
            }
            .disabled(isGeneratingExport)
            
            if let exportURL {
                ShareLink(
                    item: exportURL,
                    preview: SharePreview(
                        NSLocalizedString("problem.report.share.preview", comment: ""),
                        image: Image(systemName: "doc.text")
                    )
                ) {
                    Label(NSLocalizedString("problem.report.share", comment: ""), systemImage: "square.and.arrow.up")
                }
            }
        }
    }
    
    private func reloadEvents() {
        recentEvents = Array(DiagnosticsLogger.shared.recentEvents(limit: 50).reversed())
    }
    
    private func generateExport() {
        guard preferences.diagnosticsConsent else {
            showGenerationError = true
            return
        }
        
        isGeneratingExport = true
        DispatchQueue.global(qos: .utility).async {
            let url = DiagnosticsLogger.shared.export(forUserIdentifier: preferences.diagnosticsUserIdentifier)
            DispatchQueue.main.async {
                if let url {
                    self.exportURL = url
                    DiagnosticsLogger.shared.log(
                        level: .info,
                        message: "Diagnostics export generated",
                        metadata: ["path": url.lastPathComponent]
                    )
                } else {
                    self.showGenerationError = true
                }
                self.isGeneratingExport = false
            }
        }
    }
    
    private func formattedTimestamp(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
