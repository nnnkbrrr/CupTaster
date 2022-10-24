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
#warning("переписать тесты")
#warning("нельзя изменить кол-во чашек в ски и тд")
#warning("если образков много, то приложение сильно зависает")
#warning("добавить дополнительные атрибуты оценки образцов")
#warning("подсказки не написаны")
#warning("добавить формы SCI COE")
#warning("Показывать предупреждение что все образцы/каппинги будут удалены при удалении каппинга/формы")
#warning("unit тесты")

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
