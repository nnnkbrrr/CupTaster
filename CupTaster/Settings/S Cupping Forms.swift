//
//  CuppingForms.swift
//  CupTaster
//
//  Created by Никита on 08.09.2022.
//

import SwiftUI
import CoreData

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
                                    cfManager.defaultCFDescription = cuppingForm.shortDescription
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark")
                                        .frame(width: 30)
                                        .opacity(cuppingForm.isSelected(defaultCFDescription: cfManager.defaultCFDescription) ? 1 : 0)
                                    Divider()
                                        .padding(.vertical, 5)
                                    Text(cuppingForm.title)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .frame(maxWidth: .infinity)
                            
                            NavigationLinkButton(
                                destination: CuppingFormInfoView(moc: moc, cuppingForm: cuppingForm),
                                label: { Image(systemName: "info.circle") }
                            )
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
                                if let addedForm = cfModel.createCuppingForm(context: moc) {
                                    withAnimation {
                                        cfManager.defaultCFDescription = addedForm.shortDescription
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "plus")
                                        .frame(width: 30)
                                    Divider()
                                        .padding(.vertical, 5)
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
                        HStack {
                            Button {
                                withAnimation {
                                    cfManager.defaultCFDescription = cuppingForm.shortDescription
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark")
                                        .frame(width: 30)
                                        .opacity(cuppingForm.isSelected(defaultCFDescription: cfManager.defaultCFDescription) ? 1 : 0)
                                    Divider()
                                        .padding(.vertical, 5)
                                    Text("\(cuppingForm.title) v. \(cuppingForm.version) - \(cuppingForm.languageCode)")
                                    Spacer()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            NavigationLinkButton(
                                destination: CuppingFormInfoView(moc: moc, cuppingForm: cuppingForm),
                                label: { Image(systemName: "info.circle") }
                            )
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

#warning("cf navigation link page")
struct CuppingFormInfoView: View {
    let moc: NSManagedObjectContext
    let cuppingForm: CuppingForm
    
    var body: some View {
        VStack {
            Text("this is \(cuppingForm.title)")
            Text("v. \(cuppingForm.version) - \(cuppingForm.languageCode)")
            Button {
                moc.delete(cuppingForm)
                try? moc.save()
            } label: {
                Text("Delete")
                    .foregroundColor(.red)
                    .padding()
                    .padding(.horizontal)
                    .background(Color(uiColor: .systemGray5))
                    .cornerRadius(10)
            }
            .padding(.top, 50)
        }
    }
}
