//
//  ContentView.swift
//  CupTaster
//
//  Created by Никита on 09.04.2022.
//

import SwiftUI
import CoreData

#warning("локализация на английском")

// MARK: Content View

struct ContentView: View {
    @FetchRequest(entity: CuppingForm.entity(), sortDescriptors: []) var cuppingForms: FetchedResults<CuppingForm>
    
    var body: some View {
        TabView {
            AllCuppingsView()
                .tabItem { Label("Cuppings", systemImage: "cup.and.saucer") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .badge(CFManager.shared.newerVersionsAvailability(from: cuppingForms))
        }
        .modifier(Onboarding())
    }
}
