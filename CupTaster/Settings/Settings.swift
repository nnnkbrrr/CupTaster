//
//  Settings.swift
//  CupTaster
//
//  Created by Никита on 11.07.2022.
//

import SwiftUI

#warning("This called 'Settings'?????")

struct SettingsView: View {
    @Binding var selectedCuppingForm: Int
    @AppStorage("use-cupping-hints") var useCuppingHints: Bool = false
    
    #warning("developer tools")
    @AppStorage("onboarding-completed") var onboardingCompleted: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Cuppings") {
                    NavigationLink(destination: SettingsCuppingFormsView()) {
                        Text("Cupping Form - (SCA)")
                    }
                    Toggle("Cupping hints", isOn: $useCuppingHints)
                }
                
                Section("Test tools") {
                    Button {
                        onboardingCompleted = false
                    } label: {
                        Text("Show onboarding on next launch")
                    }
                }
                
#warning("in future")
//                Section {
//                    Text("Tip jar")
//                    Text("Contact")
//                    Text("Help with translation")
//                    Text("Share app")
//                    Text("version 1.0")
//                }
            }
            .navigationTitle("Settings")
        }
    }
}
