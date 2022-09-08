//
//  CuppingForms.swift
//  CupTaster
//
//  Created by Никита on 08.09.2022.
//

import SwiftUI

struct NavigationLinkButton<Label: View, Destination: View>: View {
    let destination: Destination
    @ViewBuilder var label: Label
    
    @State var isActive: Bool = false
    
    init(destination: Destination, @ViewBuilder label: @escaping () -> Label) {
        self.destination = destination
        self.label = label()
    }
    
    var body: some View {
        Button { isActive = true } label: { label }
            .background (
                NavigationLink(destination: destination, isActive: $isActive) { EmptyView() }.hidden()
            )
    }
}

#warning("notification if new cupping form is available")

struct SettingsCuppingFormsView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(entity: CuppingForm.entity(), sortDescriptors: []) var cuppingForms: FetchedResults<CuppingForm>
    
    @ObservedObject var cfManager: CFManager = .init()
    
    var body: some View {
        let allCFModels = cfManager.allCFModels
        
        List {
            let addedCuppingForms = cfManager.allCFModels.compactMap { $0.getCF_ifAdded(storedCuppingForms: cuppingForms) }
            if addedCuppingForms.count > 0 {
                Section {
                    ForEach(addedCuppingForms) { cuppingForm in
                        HStack {
                            Button {
                                withAnimation {
                                    cfManager.defaultCF_hashedID = cuppingForm.id.hashValue
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark")
                                        .frame(width: 30)
                                        .opacity(cuppingForm.isSelected(defaultCF_hashedID: cfManager.defaultCF_hashedID) ? 1 : 0)
                                    Divider()
                                        .padding(.vertical, 5)
                                    Text(cuppingForm.title)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .frame(maxWidth: .infinity)
                            
                            NavigationLinkButton(destination: Text("Cupping form info"), label: { Image(systemName: "info.circle") })
                        }
                    }
                } header: {
                    Text("Added")
                }
            }
            
            let availableCFsModels = allCFModels.filter { $0.getCF_ifAdded(storedCuppingForms: cuppingForms) == nil }
            if availableCFsModels.count > 0 {
                Section {
                    ForEach(availableCFsModels) { cfModel in
                        HStack {
                            Button {
                                withAnimation {
                                    if let addedForm = cfModel.createCuppingForm(context: moc) {
                                        cfManager.defaultCF_hashedID = addedForm.id.hashValue
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(cfModel.title)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .frame(maxWidth: .infinity)
                            
                            NavigationLinkButton(destination: Text("Cupping form info"), label: { Image(systemName: "info.circle") })
                        }
                    }
                } header: {
                    Text("Available")
                }
            }
            
            let deprecatedCuppingForms = cuppingForms.filter { $0.isDeprecated }
            if deprecatedCuppingForms.count > 0 {
                Section {
                    ForEach(deprecatedCuppingForms) { cuppingForm in
                        Button {
                            cfManager.defaultCF_hashedID = cuppingForm.id.hashValue
                        } label: {
                            HStack {
                                Image(systemName: "checkmark")
                                    .frame(width: 30)
                                    .opacity(cuppingForm.isSelected(defaultCF_hashedID: cfManager.defaultCF_hashedID) ? 1 : 0)
                                Divider()
                                    .padding(.vertical, 5)
                                Text(cuppingForm.title)
                                Spacer()
                            }
                        }
                    }
                } header: {
                    Label("Deprecated", systemImage: "exclamationmark.triangle")
                }
            }
        }
        .buttonStyle(BorderlessButtonStyle())
        .navigationBarTitle("Cupping forms")
    }
}
