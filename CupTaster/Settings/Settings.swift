//
//  Settings.swift
//  CupTaster
//
//  Created by Никита on 11.07.2022.
//

import SwiftUI

struct SettingsView: View {
    @FetchRequest(entity: CuppingForm.entity(), sortDescriptors: []) var cuppingForms: FetchedResults<CuppingForm>
    @Binding var selectedCuppingFormID: String
    
    @AppStorage("use-cupping-hints")
    var useCuppingHints: Bool = false
    
    @AppStorage("sample-name-generator-method")
    var sampleNameGenerationMethod: SampleNameGenerator.GenerationMethod = .alphabetical
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: SettingsCuppingFormsView()) {
                        let defaultCuppingTitle: CuppingForm? = CFManager().getDefaultCuppingForm(from: cuppingForms)
                        if let defaultCuppingTitle {
                            Text("Cupping form: \(defaultCuppingTitle.title)")
                        } else {
                            Text("Cupping form is not selected")
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
                
#warning("in future")
                Section {
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
