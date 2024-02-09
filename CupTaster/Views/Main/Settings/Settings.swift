//
//  Settings.swift
//  CupTaster
//
//  Created by Никита Баранов on 11.07.2023.
//

import SwiftUI

struct SettingsTabView: View {
    @AppStorage("sample-name-generator-method") var generationMethod: SampleNameGeneratorModel.GenerationMethod = .alphabetical
    let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "???"
    let buildVersion: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "???"
    let systemVersion: String = UIDevice.current.systemVersion
    let languageCode: String = Locale.current.languageCode ?? "-"
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .extraSmall) {
                
                // MARK: - Main
                
                NavigationSettingsSection(title: "Default Cupping Form", systemImageName: "doc.plaintext") {
                    Settings_CuppingForms()
                }
                
#warning("section")
                NavigationSettingsSection(title: "General Info Fields", systemImageName: "info") {
                    Text("Empty")
                }
                .disabled(true)
                
#warning("section")
                NavigationSettingsSection(title: "Folders", systemImageName: "folder") {
                    Text("Empty")
                }
                .disabled(true)
                
                // MARK: - Conditional
                
                SettingsHeader("Conditional")
                
                ToggleSettingsSection(title: "Alternative sample names", systemImageNames: (on: "abc", off: "textformat.123"), isOn: Binding(
                    get: { generationMethod == .alphabetical },
                    set: { generationMethod = $0 ? .alphabetical : .numerical })
                )
                
#warning("section")
                ToggleSettingsSection(title: "Attach location", systemImageNames: (on: "location.fill", off: "location.slash"), isOn: .constant(false))
                    .opacity(0.5)
                    .disabled(true)
                
#warning("section")
                ToggleSettingsSection(title: "Reset stopwatch in 1h", systemImageNames: (on: "clock.arrow.circlepath", off: "clock"), isOn: .constant(false))
                    .opacity(0.5)
                    .disabled(true)
                
                // MARK: - Contacts
                
                SettingsHeader("Contacts")
                
                ButtonSettingsSection(title: "Contact us", systemImageName: "envelope") {
                    EmailManager.shared.send(
                        body: emailMessage,
                        to: "support-cuptaster@nnnkbrrr.space"
                    )
                }
                
#warning("section")
                NavigationSettingsSection(title: "Help with translation", systemImageName: "globe") {
                    Text("Empty")
                }
                .disabled(true)
                
                VStack(spacing: .extraSmall) {
#warning("Text")
                    Text("Last iCloud Sync: #DD.MM.YYYY at HH:MM#")
                    Text("Version \(appVersion) (\(buildVersion))")
                }
                .font(.subheadline)
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
                .onTapGesture(count: 10) {
                    print("tester tab visible")
                    //                        testerTabVisible = true
#warning("Tester section")
                }
            }
            .padding(.small)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Settings")
        .defaultNavigationBar()
    }
}

// MARK: Standart Sections

extension SettingsTabView {
    struct SettingsHeader: View {
        let title: String
        
        init(_ title: String) {
            self.title = title
        }
        
        var body: some View {
            Text(title)
                .font(.subheadline)
                .bold()
                .frame(height: 40, alignment: .bottom)
                .padding(.leading, .small)
        }
    }
    
    struct ButtonSettingsSection: View {
        let title: String
        let systemImageName: String
        let action: () -> ()
        
        init(title: String, systemImageName: String, action: @escaping () -> ()) {
            self.title = title
            self.systemImageName = systemImageName
            self.action = action
        }
        
        var body: some View {
            Button {
                action()
            } label: {
                SettingsSection(title: title, systemImageName: systemImageName) { LeadingNavigationIndicator() }
            }
            .buttonStyle(.plain)
        }
    }
    
    struct NavigationSettingsSection<Destination: View>: View {
        let title: String
        let systemImageName: String
        let destination: () -> Destination
        
        init(title: String, systemImageName: String, destination: @escaping () -> Destination) {
            self.title = title
            self.systemImageName = systemImageName
            self.destination = destination
        }
        
        var body: some View {
            NavigationLink(destination: destination) {
                SettingsSection(title: title, systemImageName: systemImageName) { LeadingNavigationIndicator() }
            }
            .buttonStyle(.plain)
        }
    }
    
    struct ToggleSettingsSection: View {
        let title: String
        let systemImageNames: (on: String, off: String)
        @Binding var isOn: Bool
        
        var body: some View {
            SettingsSection(title: title, systemImageName: Binding(get: { isOn ? systemImageNames.on : systemImageNames.off }, set: { _ in })) {
                Toggle("", isOn: $isOn)
                    .labelsHidden()
            }
        }
    }
}

// MARK: Styles

extension SettingsTabView {
    private struct SettingsSection<LeadingContent: View>: View {
        let title: String
        @Binding var systemImageName: String
        let leadingContent: () -> LeadingContent
        
        init(title: String, systemImageName: Binding<String>, leadingContent: @escaping () -> LeadingContent) {
            self.title = title
            self._systemImageName = systemImageName
            self.leadingContent = leadingContent
        }
        
        init(title: String, systemImageName: String, leadingContent: @escaping () -> LeadingContent) {
            self.title = title
            self._systemImageName = .constant(systemImageName)
            self.leadingContent = leadingContent
        }
        
        var body: some View {
                HStack {
                    Image(systemName: systemImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.gray)
                        .background(Color.backgroundTertiary)
                        .cornerRadius()
                    
                    Text(title)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    leadingContent()
                }
                .frame(height: 60)
                .padding(.horizontal, 10)
                .background(Color.backgroundSecondary)
                .cornerRadius()
        }
    }
    
    private struct LeadingNavigationIndicator: View {
        var body: some View {
            Image(systemName: "chevron.right")
                .font(.body.bold())
                .foregroundStyle(.gray)
                .padding(.trailing, 10)
        }
    }
}

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
