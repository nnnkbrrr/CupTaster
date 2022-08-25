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
    
    @State private var newCuppingName: String = ""
    @FocusState private var newCuppingNameFocused: Bool
    @State var activeCupping: ObjectIdentifier? = nil
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ZStack {
                        HStack {
                            Button {
                                newCuppingName = ""
                                withAnimation { newCuppingNameFocused = false }
                                
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
                        .opacity(newCuppingNameFocused ? 1 : 0)
                        .buttonStyle(BorderlessButtonStyle())
                        
                        if !newCuppingNameFocused {
                            Button {
                                withAnimation { newCuppingNameFocused = true }
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("New cupping")
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                
                Section {
                    ForEach(cuppings) { cupping in
                        CuppingView(cupping: cupping).preview(selection: $activeCupping)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Text("\(cuppings.count) cuppings, \(samples.count) samples")
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .principal) { Text(" ") }
                StopwatchToolbarItem()
            }
            .navigationTitle("All Сuppings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
    
    func addNewCupping() {
        let newCupping: Cupping = Cupping(context: moc)
        newCupping.name = newCuppingName
        newCupping.date = Date()
        
        newCuppingName = ""
        newCuppingNameFocused = false
        try? moc.save()
        
        activeCupping = newCupping.id
    }
}
