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
    init() {
        // navigation bar background always opaque
        let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
    
    @FetchRequest(entity: CuppingForm.entity(), sortDescriptors: []) var cuppingForms: FetchedResults<CuppingForm>
    
    var body: some View {
        TabView {
            AllCuppingsTabView()
                .tabItem { Label("Cuppings", systemImage: "cup.and.saucer") }

            SettingsTabView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
#warning("badge?")
//                .badge(CFManager.shared.newerVersionsAvailability(from: cuppingForms))
        }
#warning("onboarding")
//        .modifier(Onboarding())
    }
}
