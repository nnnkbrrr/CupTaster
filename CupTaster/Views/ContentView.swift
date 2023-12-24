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
    @FetchRequest(entity: CuppingForm.entity(), sortDescriptors: []) var cuppingForms: FetchedResults<CuppingForm>
    
    @ObservedObject var sampleControllerModel: SamplesControllerModel = .shared
    
    init() {
        // navigation bar background always opaque
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
    
    var body: some View {
        ZStack {
            AllCuppingsTabView()
                .tabItem { Label("Cuppings", systemImage: "cup.and.saucer") }
            
            SamplesControllerView()
                .zIndex(1)
        }
#warning("onboarding")
        //.modifier(Onboarding())
    }
}
