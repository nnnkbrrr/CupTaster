//
//  Settings.swift
//  CupTaster
//
//  Created by Никита on 11.07.2022.
//

import SwiftUI

struct SettingsView: View {
    @FetchRequest(entity: CuppingForm.entity(), sortDescriptors: []) var cuppingForms: FetchedResults<CuppingForm>
    
    @AppStorage("use-cupping-hints")
    var useCuppingHints: Bool = false
    
    @AppStorage("sample-name-generator-method")
    var sampleNameGenerationMethod: SampleNameGenerator.GenerationMethod = .alphabetical
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: SettingsCuppingFormsView()) {
                        let defaultCuppingTitle: CuppingForm? = CFManager.shared.getDefaultCuppingForm(from: cuppingForms)
                        if let defaultCuppingTitle {
                            Text("Cupping form: \(defaultCuppingTitle.title)")
                        } else {
                            Label("Cupping form need to be added", systemImage: "exclamationmark.triangle")
                                .foregroundColor(.red)
                        }
                    }
                    
                    Toggle("Use hints", isOn: $useCuppingHints)
                    
                    Picker("Sample name generation", selection: $sampleNameGenerationMethod) {
                        Text("alphabetical").tag(SampleNameGenerator.GenerationMethod.alphabetical)
                        Text("numerical").tag(SampleNameGenerator.GenerationMethod.numerical)
                    }
                } header: {
                    Text("Cuppings")
                }
                
                Section {
#warning("in future")
                    //Text("Tip jar")
                    
                    Button("Contact") { EmailHelper.shared.send(to: "support-cuptaster@nnnkbrrr.space") }
                    Button("Help with translation") { EmailHelper.shared.send(
                        subject: "Cuptaster localization",
                        to: "support-cuptaster@nnnkbrrr.space"
                    ) }
                } footer: {
                    Text("app version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
