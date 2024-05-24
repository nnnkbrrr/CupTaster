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
    
    @AppStorage("purchase-identifier") var purchaseIdentifier: String = ""
    
    var body: some View {
        Group {
            if onboardingIsCompleted && !iCloudLoading && !testingManager.showOnboarding {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    ZStack {
                        MainTabView()
                        SamplesControllerView().opacity(testingManager.hideSampleOverlay ? 0 : 1)
                    }
                    .allowsHitTesting(!samplesControllerModel.isTogglingVisibility)
                } else {
                    HStack(spacing: 0) {
                        MainTabView()
                            .zIndex(2)
                        if samplesControllerModel.isActive {
                            Divider()
                        }
                        SamplesControllerView().opacity(testingManager.hideSampleOverlay ? 0 : 1)
                            .clipped()
                            .zIndex(1)
                            .background(Color.backgroundPrimary, ignoresSafeAreaEdges: .all)
                    }
                }
            } else {
                ZStack {
                    if syncMonitor.syncStateSummary.inProgress && iCloudLoading == true {
                        OnboardingView.iCloudLoadingView()
                            .onDisappear {
                                if cuppingForms.count > 0 {
                                    onboardingIsCompleted = true
                                    purchaseIdentifier = UUID().uuidString
                                }
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
