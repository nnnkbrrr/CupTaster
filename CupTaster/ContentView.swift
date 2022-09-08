//
//  ContentView.swift
//  CupTaster
//
//  Created by Никита on 09.04.2022.
//

import SwiftUI
import CoreData

// MARK: Content View

struct ContentView: View {
    var body: some View {
        TabView {
            AllCuppingsView()
                .tabItem { Label("Cuppings", systemImage: "cup.and.saucer") }
            
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .modifier(OnboardingSheet())
    }
}

#warning("Возможные unit тесты")
// Проверить соответствие версий установленной и актуальной каппинговой

struct AllCuppingsView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: Cupping.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Cupping.date, ascending: false)]
    ) var cuppings: FetchedResults<Cupping>
    @FetchRequest(entity: Sample.entity(), sortDescriptors: []) var samples: FetchedResults<Sample>
    
    @State private var newCuppingName: String = ""
    @State private var newCuppingNameVisible: Bool = false
    @FocusState private var newCuppingNameFocused: Bool
    @State var activeCupping: ObjectIdentifier? = nil
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    if newCuppingNameVisible {
                        HStack {
                            Button {
                                newCuppingName = ""
                                withAnimation { newCuppingNameVisible = false }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .contentShape(Rectangle())
                            }
                            
                            TextField("New cupping name", text: $newCuppingName) { addNewCupping() }
                                .submitLabel(.done)
                                .focused($newCuppingNameFocused, equals: true)
                            
                            Button {
                                addNewCupping()
                            } label: {
                                Image(systemName: "checkmark.circle.fill")
                                    .contentShape(Rectangle())
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .onAppear { newCuppingNameFocused = true }
                    }
                    
                    ForEach(cuppings) { cupping in
                        CuppingView(cupping: cupping).preview(selection: $activeCupping)
                    }
                } header: {
                    Text("\(cuppings.count) cuppings, \(samples.count) samples")
                }
            }
            .toolbar {
                StopwatchToolbarItem()
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation { newCuppingNameVisible = true }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationTitle("All Сuppings")
        }
        .navigationViewStyle(.stack)
    }
    
    func addNewCupping() {
        let newCupping: Cupping = Cupping(context: moc)
        newCupping.name = newCuppingName
        newCupping.date = Date()
        
        newCuppingName = ""
        newCuppingNameFocused = false
        newCuppingNameVisible = false
        try? moc.save()
        
        activeCupping = newCupping.id
    }
}
