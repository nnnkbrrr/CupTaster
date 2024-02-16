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
    @State var showLocationAuthorizationSheet: Bool = false
    
    @ObservedObject var testingManager: TestingManager = .shared
    @ObservedObject var syncMonitor: SyncMonitor = .shared
    @ObservedObject var stopwatchModel: StopwatchModel = .shared
    @ObservedObject var locationManager: LocationManager = .shared
    
    let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "???"
    let buildVersion: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "???"
    let systemVersion: String = UIDevice.current.systemVersion
    let languageCode: String = Locale.current.languageCode ?? "-"
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .extraSmall) {
                
                // MARK: - Main
                
                SettingsNavigationSection(title: "Default Cupping Form", systemImageName: "doc.plaintext") { Settings_CuppingFormsView() }
                
#warning("section")
                SettingsNavigationSection(title: "General Info Fields", systemImageName: "info") {
                    Text("Empty")
                }
                .disabled(true)
                
#warning("section")
                SettingsNavigationSection(title: "Folders", systemImageName: "folder") {
                    Text("Empty")
                }
                .disabled(true)
                
                // MARK: - Conditional
                
                SettingsHeader("Conditional")
                
                SettingsToggleSection(title: "Alternative sample names", systemImageNames: (on: "abc", off: "textformat.123"), isOn: Binding(
                    get: { generationMethod == .alphabetical },
                    set: { generationMethod = $0 ? .alphabetical : .numerical }
                ))
                
                SettingsToggleSection(title: "Attach location", systemImageNames: (on: "location.fill", off: "location.slash"), isOn: Binding(
                    get: { locationManager.authorized && locationManager.attachLocation },
                    set: { value in
                        if locationManager.authorized {
                            locationManager.attachLocation = value
                        } else {
                            if locationManager.authorizationStatus == .notDetermined {
                                locationManager.requestAuthorization()
                            } else {
                                showLocationAuthorizationSheet = true
                            }
                            
                            locationManager.attachLocation = value
                        }
                    }
                ))
                .adaptiveSizeSheet(isPresented: $showLocationAuthorizationSheet) {
                    VStack(spacing: .large) {
                        Text("Access denied")
                            .font(.title.bold())
                        
                        Image(systemName: "location.slash")
                            .font(.system(size: 100, weight: .light))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.gray)
                        
                        Text("Turn on Location Services in settings to allow CupTaster determine your location.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.gray)
                        
                        Button {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        } label: {
                            Text("Go to settings ") + Text(Image(systemName: "arrow.right"))
                        }
                        .buttonStyle(.primary)
                    }
                    .padding([.horizontal, .bottom], .small)
                }
                
                SettingsToggleSection(title: "Reset stopwatch in 1h", systemImageNames: (on: "clock.arrow.circlepath", off: "clock"), isOn: stopwatchModel.$resetInAnHour)
                
                // MARK: - Contacts
                
                SettingsHeader("Contacts")
                
                SettingsButtonSection(title: "Contact us", systemImageName: "envelope") {
                    EmailManager.shared.send(
                        body: emailMessage,
                        to: "support-cuptaster@nnnkbrrr.space"
                    )
                } leadingContent: {
                    SettingsLeadingNavigationIndicator()
                }
                
#warning("section")
                SettingsNavigationSection(title: "Help with translation", systemImageName: "globe") {
                    Text("Empty")
                }
                .disabled(true)
                
                // MARK: - Tester
                
                if testingManager.isVisible {
                    SettingsHeader("Tester")
                    
                    SettingsNavigationSection(title: "Tester", systemImageName: "wrench.and.screwdriver") {
                        Settings_TesterView()
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
                    testingManager.isVisible = true
                }
            }
            .padding(.small)
        }
        .background(Color.backgroundPrimary)
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
