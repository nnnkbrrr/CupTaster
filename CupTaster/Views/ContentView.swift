//
//  ContentView.swift
//  CupTaster
//
//  Created by Никита on 09.04.2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @FetchRequest(entity: CuppingForm.entity(), sortDescriptors: []) var cuppingForms: FetchedResults<CuppingForm>
    
    @ObservedObject var sampleControllerModel: SamplesControllerModel = .shared
    
    var body: some View {
        ZStack {
            MainTabView()
            SamplesControllerView()
        }
        .allowsHitTesting(sampleControllerModel.isTogglingVisibility ? false : true)
#warning("onboarding // show icloud sync if data exist")
        //.modifier(Onboarding())
    }
}
