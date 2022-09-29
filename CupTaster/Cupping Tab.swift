//
//  CuppingTabView.swift
//  CupTaster
//
//  Created by Никита on 12.09.2022.
//

import SwiftUI

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
    @State var selectedCupping: Cupping? = nil
    
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
                        Button {
                            selectedCupping = cupping
                        } label: {
                            Text(cupping.name)
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            moc.delete(cuppings[index])
                            try? moc.save()
                        }
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
        .fullScreenCover(item: $selectedCupping, content: { CuppingView(cupping: $0) })
    }
    
    func addNewCupping() {
        let newCupping: Cupping = Cupping(context: moc)
        newCupping.name = newCuppingName
        newCupping.date = Date()
        
        newCuppingName = ""
        newCuppingNameFocused = false
        newCuppingNameVisible = false
        try? moc.save()
        
        selectedCupping = newCupping
    }
}
