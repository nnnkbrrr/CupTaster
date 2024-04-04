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
    @FetchRequest(entity: SampleGeneralInfo.entity(), sortDescriptors: []) var generalInfoFields: FetchedResults<SampleGeneralInfo>
    
    @AppStorage("onboarding-is-completed") var onboardingIsCompleted: Bool = false
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    @ObservedObject var testingManager: TestingManager = .shared
    @ObservedObject var syncMonitor: SyncMonitor = .shared
    
    @State var iCloudLoading = false
    
    var body: some View {
        Group {
            if onboardingIsCompleted && !iCloudLoading && !testingManager.showOnboarding {
                ZStack {
                    MainTabView()
                    SamplesControllerView().opacity(testingManager.hideSampleOverlay ? 0 : 1)
                }
                .allowsHitTesting(!samplesControllerModel.isTogglingVisibility)
            } else {
                ZStack {
                    if syncMonitor.syncStateSummary.inProgress && iCloudLoading == true {
                        OnboardingView.iCloudLoadingView()
                            .onDisappear {
                                if cuppingForms.count > 0 { onboardingIsCompleted = true }
                            }
                    } else {
                        OnboardingView(onboardingIsCompleted: $onboardingIsCompleted, generalInfoFields: generalInfoFields)
                            .onAppear {
                                iCloudLoading = false
                            }
                    }
                }
                .onAppear { iCloudLoading = true }
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                if testingManager.testerOverlayIsVisible {
                    TesterPanelView().ignoresSafeArea(.keyboard)
                }
            }
        }
    }
}
