//
//  Settings.swift
//  CupTaster
//
//  Created by Никита on 11.07.2022.
//

import SwiftUI

struct SettingsView: View {
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
                        Text("Cupping form: SCA")
                    }
                    
                    Picker("Sample name generation", selection: $sampleNameGenerationMethod) {
                        Text("alphabetical").tag(SampleNameGenerator.GenerationMethod.alphabetical)
                        Text("numerical").tag(SampleNameGenerator.GenerationMethod.numerical)
                    }
                    
                    Toggle("Use hints", isOn: $useCuppingHints)
                } header: {
                    Text("Cuppings")
                } footer: {
                    Text("app version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")")
                }
                
#warning("in future")
//                Section {
//                    Text("Tip jar")
//                    Text("Contact")
//                    Text("Help with translation")
//                    Text("Share app")
//                }
            }
            .navigationTitle("Settings")
        }
    }
}
