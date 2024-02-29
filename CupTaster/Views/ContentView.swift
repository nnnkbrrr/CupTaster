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
    
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    @ObservedObject var testingManager: TestingManager = .shared
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                MainTabView()
                SamplesControllerView()
            }
            .allowsHitTesting(!samplesControllerModel.isTogglingVisibility)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    if testingManager.testerOverlayIsVisible {
                        TesterPanelView().ignoresSafeArea(.keyboard)
                    }
                }
            }
#warning("onboarding // show icloud sync if data exist")
            //.modifier(Onboarding())
        }
    }
}
