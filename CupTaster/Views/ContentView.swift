//
//  ContentView.swift
//  CupTaster
//
//  Created by Никита on 09.04.2022.
//

import SwiftUI
import CoreData

// MARK: Content View

#warning("пересмотреть структуру в Cupping папке (ВСЮ!)")

struct ContentView: View {
    var body: some View {
        TabView {
            AllCuppingsView()
                .tabItem {
                    Label("Cuppings", systemImage: "cup.and.saucer")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .modifier(OnboardingSheet())
    }
}

struct AllCuppingsView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: Cupping.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Cupping.date, ascending: false)]
    ) var cuppings: FetchedResults<Cupping>
    @FetchRequest(entity: Sample.entity(), sortDescriptors: []) var samples: FetchedResults<Sample>
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: NewCuppingView()) {
                        Label("New cupping", systemImage: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                }
                
                Section {
                    ForEach(cuppings) { cupping in
                        CuppingView(cupping: cupping).preview
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Text("\(cuppings.count) cuppings, \(samples.count) samples")
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .principal) {
                    Text(" ")
                }
                StopwatchToolbarItem()
            }
            .navigationTitle("All Сuppings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
