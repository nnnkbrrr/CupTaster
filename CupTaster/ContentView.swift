//
//  ContentView.swift
//  CupTaster
//
//  Created by Никита on 09.04.2022.
//

import SwiftUI
import CoreData

// MARK: Content View

#warning("если образцов много, то приложение сильно зависает")
#warning("таймер не пропадает если пропадает sample textfield следующего образца")
#warning("фон в просмотре всех образцов каппинга")
#warning("clipped в sample selector обрезает view при жесте выхода, без него фон клавиатуры пропадает если выйти из приложения")
#warning("geometry reader - зло, в превью самплов статус бар не на норм фоне")

struct ContentView: View {
    @FetchRequest(entity: CuppingForm.entity(), sortDescriptors: []) var cuppingForms: FetchedResults<CuppingForm>
    @AppStorage("tester-tab-visible") var testerTabVisible: Bool = false
    
    var body: some View {
        TabView {
            AllCuppingsView()
                .tabItem { Label("Cuppings", systemImage: "cup.and.saucer") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .badge(CFManager.shared.newerVersionsAvailability(from: cuppingForms))
            
            if testerTabVisible {
                TesterView()
                    .tabItem { Label("Тестировщик", systemImage: "wrench.and.screwdriver") }
            }   
        }
        .modifier(OnboardingSheet())
    }
}
