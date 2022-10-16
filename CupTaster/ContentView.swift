//
//  ContentView.swift
//  CupTaster
//
//  Created by Никита on 09.04.2022.
//

import SwiftUI
import CoreData

// MARK: Content View

#warning("внешний вид на айпадах")
#warning("внешний вид на светлой теме")
#warning("если образков много, то приложение сильно зависает")
#warning("подсказки не написаны")
#warning("добавить формы SCI COE")
#warning("Показывать предупреждение что все образцы/каппинги будут удалены при удалении каппинга/формы")

struct ContentView: View {
    @FetchRequest(entity: CuppingForm.entity(), sortDescriptors: []) var cuppingForms: FetchedResults<CuppingForm>
    var body: some View {
        TabView {
            AllCuppingsView()
                .tabItem { Label("Cuppings", systemImage: "cup.and.saucer") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .badge(CFManager.shared.newerVersionsAvailability(from: cuppingForms))
            
#warning("test tools")
            TesterView()
                .tabItem { Label("Тестировщик", systemImage: "wrench.and.screwdriver") }
        }
        .modifier(OnboardingSheet())
    }
}
