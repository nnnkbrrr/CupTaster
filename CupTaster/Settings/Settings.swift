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
    
    var body: some View {
        NavigationView {
            Form {
                Section(" ") {
                    NavigationLink {
                        Form {
                            Settings_CFSelectorFormSectionsView()
                        }.navigationTitle("Cupping Form")
                    } label: { Label("Cupping Form", systemImage: "doc.on.clipboard") }
                    
                    NavigationLink {
                        Form {
                            Section("By default") {
                                Button {
                                    sampleNameGenerationMethod = .alphabetical
                                } label: {
                                    Label {
                                        Text("Letters")
                                    } icon: {
                                        Image(systemName: "checkmark")
                                            .opacity(sampleNameGenerationMethod == .alphabetical ? 1 : 0)
                                    }
                                }
                                
                                Button {
                                    sampleNameGenerationMethod = .numerical
                                } label: {
                                    Label {
                                        Text("Numbers")
                                    } icon: {
                                        Image(systemName: "checkmark")
                                            .opacity(sampleNameGenerationMethod == .numerical ? 1 : 0)
                                    }
                                }
                            }
                        }.navigationTitle("Default samples name")
                    } label: { Label(
                        "Default samples name",
                        systemImage: sampleNameGenerationMethod == .numerical ?
                        "textformat.123" : "abc"
                    )}
                    
                    NavigationLink {
                        Settings_GeneralInfoView()
                            .navigationTitle("Additional fields")
                    } label: { Label("Additional fields", systemImage: "info.circle") }
                    
                    NavigationLink {
                        Settings_Slider()
                            .navigationTitle("Customization")
                    } label: { Label("Customization", systemImage: "circle.lefthalf.filled") }
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
                
                if testerTabVisible {
                    Section {
                        NavigationLink {
                            TesterView()
                                .navigationTitle("Tester")
                        } label: { Label("Tester", systemImage: "wrench.and.screwdriver") }
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
