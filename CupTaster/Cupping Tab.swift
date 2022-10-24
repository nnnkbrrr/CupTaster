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
    @FetchRequest(entity: CuppingForm.entity(), sortDescriptors: []) var cuppingForms: FetchedResults<CuppingForm>
    @FetchRequest(entity: Sample.entity(), sortDescriptors: []) var samples: FetchedResults<Sample>
    
    @State private var newCuppingName: String = ""
    @State private var newCuppingNameVisible: Bool = false
    @FocusState private var newCuppingNameFocused: Bool
    @State var activeCuppingModel: CuppingModel? = nil
    
    var body: some View {
        if CFManager.shared.getDefaultCuppingForm(from: cuppingForms) == nil {
            VStack(spacing: 30) {
                Text("No cupping forms are available")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                
                Text("Please add at least one cupping form in settings")
            }
            .multilineTextAlignment(.center)
            .padding(30)
        } else {
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
                        } else {
                            Button {
                                withAnimation { newCuppingNameVisible = true }
                            } label: {
                                Label("New cupping", systemImage: "plus")
                            }
                        }

                        ForEach(cuppings) { cupping in
                            Button {
                                activeCuppingModel = CuppingModel(cupping: cupping)
                            } label: {
                                VStack(spacing: 5) {
                                    Text(cupping.name)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    HStack {
                                        HStack {
                                            Text("\(cupping.form?.title ?? "-")")
                                            Divider()
                                                .frame(height: 15)
                                            Text("\(cupping.samples.count) samples x \(cupping.cupsCount) cups")
                                            let favoritesCount: Int = cupping.samples.filter{ $0.isFavorite }.count
                                            if favoritesCount > 0 {
                                                Divider()
                                                    .frame(height: 15)
                                                Text("\(favoritesCount)")
                                                Image(systemName: "heart.fill")
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Text(cupping.date, style: .date)
                                    }
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                }
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
                .toolbar { StopwatchToolbarItem() }
                .navigationTitle("All Сuppings")
            }
            .fullScreenCover(item: $activeCuppingModel, content: { CuppingView(cuppingModel: $0) })
        }
    }
    
    func addNewCupping() {
        let newCupping: Cupping = Cupping(context: moc)
        newCupping.name = newCuppingName
        newCupping.date = Date()
        
        newCuppingName = ""
        newCuppingNameFocused = false
        newCuppingNameVisible = false
        try? moc.save()
        
        activeCuppingModel = CuppingModel(cupping: newCupping)
    }
}
