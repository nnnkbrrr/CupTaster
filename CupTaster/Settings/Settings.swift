//
//  Settings.swift
//  CupTaster
//
//  Created by Никита on 11.07.2022.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("sample-name-generator-method")
    var sampleNameGenerationMethod: SampleNameGenerator.GenerationMethod = .alphabetical
    
    @State var cuppingFormInfo: CuppingForm? = nil
    @State var cfModelInfo: CFManager.CFModel? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Settings_CFSelectorFormSectionsView(cuppingFormInfo: $cuppingFormInfo)
                    .sheet(item: $cuppingFormInfo) { cuppingForm in
                        CFManager.CuppingFormInfoView(cuppingForm: cuppingForm)
                    }
                    .sheet(item: $cfModelInfo) { cfModel in
                        CFManager.CuppingFormInfoView(cfModel: cfModel)
                    }
                
                Section {
                    Label(
                        "Sample name generation",
                        systemImage: sampleNameGenerationMethod == .alphabetical ?
                        "abc" : "textformat.123"
                    )
                    .foregroundColor(.primary)
                    
                    Button {
                        sampleNameGenerationMethod = .alphabetical
                    } label: {
                        Label(
                            "alphabetical",
                            systemImage: sampleNameGenerationMethod == .alphabetical ?
                            "checkmark" : ""
                        )
                    }
                    
                    Button {
                        sampleNameGenerationMethod = .numerical
                    } label: {
                        Label(
                            "numerical",
                            systemImage: sampleNameGenerationMethod == .numerical ?
                            "checkmark" : ""
                        )
                    }
                }
                
                Section {
                    Button {
                        EmailHelper.shared.send(to: "support-cuptaster@nnnkbrrr.space")
                    } label: {
                        Label("Contact", systemImage: "envelope")
                    }
                    
                    Button {
                        EmailHelper.shared.send(
                            subject: "Cuptaster localization",
                            to: "support-cuptaster@nnnkbrrr.space"
                        )
                    } label: {
                        Label("Help with translation", systemImage: "globe")
                    }
                }
                
                Section {
                    let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
