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

struct ContentView: View {
    let sfManager: CFManager = .init()
    
    var body: some View {
        TabView {
            AllCuppingsView()
                .tabItem { Label("Cuppings", systemImage: "cup.and.saucer") }
            
            SettingsView(selectedCuppingFormID: sfManager.$defaultCFDescription)
                .tabItem { Label("Settings", systemImage: "gearshape") }
            
#warning("test tools")
            TesterView()
                .tabItem { Label("Тестировщик", systemImage: "wrench.and.screwdriver") }
        }
        .modifier(OnboardingSheet())
    }
}

struct TesterView: View {
    @AppStorage("onboarding-completed") var onboardingCompleted: Bool = false
    @FetchRequest(entity: Cupping.entity(), sortDescriptors: []) var cuppings: FetchedResults<Cupping>
    var body: some View {
        Form {
            Section("") {
                Button {
                    onboardingCompleted = false
                } label: {
                    Text("Показать приветствие при следующем запуске")
                }
            }
            
            let samPerCpg: [Int] = cuppings.map { $0.samples.count }
            let minSamPerCpg: Int = samPerCpg.min()!
            let avgSamPerCpg: Int = Int(CGFloat(samPerCpg.reduce(0, +))/CGFloat(cuppings.count))
            let maxSamPerCpg: Int = samPerCpg.max()!
            
            Section("Статистика") {
                Text("Каппингов всего: \(cuppings.count)")
                Text("Образцов всего: \(samPerCpg.reduce(0, +))")
                Text("Минимум образцов: \(minSamPerCpg)")
                Text("В среднем образцов: \(avgSamPerCpg)")
                Text("Максимум образцов: \(maxSamPerCpg)")
            }
        }
    }
}
