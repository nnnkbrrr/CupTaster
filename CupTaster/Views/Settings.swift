//
//  Settings.swift
//  CupTaster
//
//  Created by Никита on 11.07.2022.
//

import SwiftUI

#warning("This called 'Settings'?????")

struct SettingsView: View {
//    @AppStorage("selected-cupping-form") var selectedCuppingForm: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: CuppingFormSelectionView()) {
                        Text("Cupping Form - (SCA)")
                    }
                    Toggle("Cupping hints", isOn: .constant(true))
                }
                
                Section {
                    Text("Tip jar")
                    Text("Contact")
                    Text("Help with translation")
                    Text("Share app")
                    Text("version 1.0")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct CuppingFormSelectionView: View {
//    @AppStorage("selected-cupping-form") var currentCuppingForm: String = ""
    @State var currentCuppingForm: String = ""
    
    var body: some View {
        List {
            Section {
                AboutCuppingFormView(currentCuppingForm: $currentCuppingForm, title: "SCA").preview
            } header: {
                Text("Global Standart")
            }
            Section {
                AboutCuppingFormView(currentCuppingForm: $currentCuppingForm, title: "SCI").preview
                AboutCuppingFormView(currentCuppingForm: $currentCuppingForm, title: "COE").preview
            } header: {
                Text("Based on SCA")
            }
            
            Section {
                Text("Available soon")
                    .foregroundColor(.gray)
            } header: {
                Text("User created")
            }
        }
        .navigationBarTitle("Cupping Form", displayMode: .inline)
    }
}

struct AboutCuppingFormView: View {
    @Binding var currentCuppingForm: String
    let title: String
    
    var body: some View {
        Text("\(title) is a cupping form.")
    }
    
    var preview: some View {
        ZStack(alignment: .trailing) {
            Button {
//                currentCuppingForm = title
            } label: {
                HStack {
                    Image(systemName: "checkmark")
                        .opacity(currentCuppingForm == title ? 1 : 0)
                        .foregroundColor(.accentColor)
                    Text(title)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            NavigationLinkButton(destination: self) {
                Image(systemName: "info.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
        }
    }
}
