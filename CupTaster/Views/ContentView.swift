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
    
    var body: some View {
        ZStack {
            AllCuppingsTabView()
                .tabItem { Label("Cuppings", systemImage: "cup.and.saucer") }
            
            SamplesControllerView()
        }
        .allowsHitTesting(sampleControllerModel.isTogglingVisibility ? false : true)
#warning("onboarding")
        //.modifier(Onboarding())
    }
}
