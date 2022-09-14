//
//  ContentView.swift
//  CupTaster
//
//  Created by Никита on 09.04.2022.
//

import SwiftUI
import CoreData

// MARK: Content View

struct ContentView: View {
    let sfManager: CFManager = .init()
    
    var body: some View {
        TabView {
            AllCuppingsView()
                .tabItem { Label("Cuppings", systemImage: "cup.and.saucer") }
            
            SettingsView(selectedCuppingForm: sfManager.$defaultCF_hashedID)
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .modifier(OnboardingSheet())
    }
}
