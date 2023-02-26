//
//  Settings.swift
//  CupTaster
//
//  Created by Никита on 11.07.2022.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("tester-tab-visible") var testerTabVisible: Bool = false
    @AppStorage("sample-name-generator-method")
    var sampleNameGenerationMethod: SampleNameGenerator.GenerationMethod = .alphabetical
    
    @State var sgiSheetIsActive: Bool = false
    @State var sliderSpacingSheetIsActive: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Settings_CFSelectorFormSectionsView()
                
                Section("Sample name generation method") {
                    Button {
                        sampleNameGenerationMethod = .alphabetical
                    } label: {
                        Label(
                            "Alphabetical",
                            systemImage: sampleNameGenerationMethod == .alphabetical ?
                            "checkmark" : ""
                        )
                    }
                    
                    Button {
                        sampleNameGenerationMethod = .numerical
                    } label: {
                        Label(
                            "Numerical",
                            systemImage: sampleNameGenerationMethod == .numerical ?
                            "checkmark" : ""
                        )
                    }
                }
                
                Section {
                    Button {
                        sgiSheetIsActive = true
                    } label: {
                        Label("General Information Templates", systemImage: "info")
                    }
                    .sheet(isPresented: $sgiSheetIsActive) {
                        Settings_GeneralInfoView(sheetActive: $sgiSheetIsActive)
                    }
                }
                
                Section("Evaluation customization") {
                    Button("Slider") {
                        sliderSpacingSheetIsActive = true
                    }
                    .halfSheet(isPresented: $sliderSpacingSheetIsActive) {
                        Settings_Slider(isActive: $sliderSpacingSheetIsActive)
                    }
                }
                
                Section {
                    #warning("add ios version, app version, locale")
                    Button {
                        EmailHelper.shared.send(to: "support-cuptaster@nnnkbrrr.space")
                    } label: {
                        Label("Contact", systemImage: "envelope")
                    }
                    
                    Button {
                        EmailHelper.shared.send(
                            subject: "CupTaster localization",
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
                    .onTapGesture(count: 10) {
                        testerTabVisible = true
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .navigationViewStyle(.stack)
    }
}
