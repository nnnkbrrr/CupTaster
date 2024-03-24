//
//  ContentView.swift
//  CupTaster
//
//  Created by Никита on 09.04.2022.
//

import SwiftUI
import CoreData
import CloudKitSyncMonitor

struct ContentView: View {
    @FetchRequest(entity: CuppingForm.entity(), sortDescriptors: []) var cuppingForms: FetchedResults<CuppingForm>
    
    @AppStorage("onboarding-is-completed") var onboardingIsCompleted: Bool = false
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    @ObservedObject var testingManager: TestingManager = .shared
    @ObservedObject var syncMonitor: SyncMonitor = .shared
    
    @State var iCloudLoading = false
    
    var body: some View {
        if onboardingIsCompleted && !iCloudLoading {
            ZStack {
                MainTabView()
                SamplesControllerView().opacity(testingManager.hideSampleOverlay ? 0 : 1)
            }
            .allowsHitTesting(!samplesControllerModel.isTogglingVisibility)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    if testingManager.testerOverlayIsVisible {
                        TesterPanelView().ignoresSafeArea(.keyboard)
                    }
                }
            }
        } else {
            ZStack {
                if syncMonitor.syncStateSummary.inProgress && iCloudLoading == true {
                    OnboardingView.iCloudLoadingView()
                        .onDisappear {
                            if cuppingForms.count > 0 { onboardingIsCompleted = true }
                            iCloudLoading = false
                        }
                } else {
                    OnboardingView(onboardingIsCompleted: $onboardingIsCompleted)
                }
            }
            .onAppear { iCloudLoading = true }
        }
    }
}
