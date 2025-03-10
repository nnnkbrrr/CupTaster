//
//  Settings.swift
//  CupTaster
//
//  Created by Никита Баранов on 11.07.2023.
//

import SwiftUI
import CloudKitSyncMonitor

struct SettingsTabView: View {
    @AppStorage("sample-name-generator-method") var generationMethod: SampleNameGeneratorModel.GenerationMethod = .alphabetical
    
    @ObservedObject var testingManager: TestingManager = .shared
    @ObservedObject var syncMonitor: SyncMonitor = .shared
    @ObservedObject var stopwatchModel: StopwatchModel = .shared
    
    let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "???"
    let buildVersion: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "???"
    let systemVersion: String = UIDevice.current.systemVersion
    let languageCode: String = Locale.current.languageCode ?? "-"
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .extraSmall) {
                
                // MARK: - Main
                
                SettingsSection {
                    SettingsNavigationSection(title: "Default Cupping Form", systemImageName: "doc.plaintext") { Settings_CuppingFormsView() }
                    SettingsNavigationSection(title: "General Info Fields", systemImageName: "info") { Settings_GeneralInfoView() }
                    SettingsNavigationSection(title: "Folders", systemImageName: "folder") { Settings_FoldersView() }
                    SettingsNavigationSection(title: "Location", systemImageName: "location") { Settings_LocationView() }
                }
                
                // MARK: - Conditional
                
                SettingsSection("Conditional") {
                    SettingsToggleSection(title: "Alternative sample names", systemImageNames: (on: "abc", off: "textformat.123"), isOn: Binding(
                        get: { generationMethod == .alphabetical },
                        set: { generationMethod = $0 ? .alphabetical : .numerical }
                    ))
                    
                    SettingsToggleSection(title: "Reset stopwatch in 1h", systemImageNames: (on: "clock.arrow.circlepath", off: "clock"), isOn: stopwatchModel.$resetInAnHour)
                }
                
                // MARK: - Contacts
                
                SettingsSection("Contacts") {
                    SettingsButtonSection(title: "Contact us", systemImageName: "envelope") {
                        EmailManager.shared.send(
                            body: emailMessage,
                            to: "support-cuptaster@nnnkbrrr.space"
                        )
                    } trailingContent: {
                        SettingsLeadingNavigationIndicator()
                    }
                }
                
                // MARK: - Tester
                
                if testingManager.isVisible {
                    SettingsSection("Tester") {
                        SettingsToggleSection(title: "Tester overlay", systemImageNames: (on: "eye", off: "eye.slash"), isOn: $testingManager.testerOverlayIsVisible)
                    }
                }
                
                // MARK: - Info
                
                VStack(spacing: .extraSmall) {
                    HStack(spacing: .extraSmall) {
                        Text(syncMonitor.syncStateSummary.description)
                        Image(systemName: syncMonitor.syncStateSummary.symbolName)
                    }
                    
                    Text("Version \(appVersion) (\(buildVersion))")
                }
                .font(.subheadline)
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
                .onTapGesture(count: 10) {
                    testingManager.isVisible.toggle()
                }
            }
            .padding(.small)
        }
        .background(Color.backgroundPrimary, ignoresSafeAreaEdges: .all)
        .navigationTitle("Settings")
        .defaultNavigationBar()
    }
}

// MARK: etc

extension SettingsTabView {
    private var emailMessage: String {
"""


--------------------
App version: \(appVersion) (\(buildVersion))
System version: \(systemVersion)
Language code: \(languageCode)
"""
    }
}
