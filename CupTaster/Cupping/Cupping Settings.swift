//
//  Cupping settings.swift
//  CupTaster
//
//  Created by Никита on 26.09.2022.
//

import SwiftUI

struct CuppingSettingsView: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(entity: CuppingForm.entity(), sortDescriptors: []) var cuppingForms: FetchedResults<CuppingForm>
    @ObservedObject var cuppingModel: CuppingModel
    
    @State var confirmDeleteAction: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Cupping name") {
                    TextField("Cupping name", text: $cuppingModel.cupping.name)
                        .submitLabel(.done)
                        .onSubmit { try? moc.save() }
                }
                
                Section {
                    if !cuppingModel.cupping.isFault {
                        DatePicker("Date", selection: $cuppingModel.cupping.date, in: ...Date(), displayedComponents: [.date])
                    }
                    Picker("Cups per sample", selection: $cuppingModel.cupping.cupsCount) {
                        ForEach(1...5, id: \.self) { cupsCount in
                            Text("\(cupsCount)").tag(Int16(cupsCount))
                        }
                    }
                    Picker("CuppingForm", selection: $cuppingModel.cupping.form) {
                        ForEach(cuppingForms) { cuppingForm in
                            Text(cuppingForm.title).tag(cuppingForm)
                        }
                    }
                    .disabled(cuppingModel.cupping.samples.count != 0)
                } header: {
                    Text("General Information")
                } footer: {
                    Text("NOTE: You cannot edit the cupping form when samples are added")
                }
                
                if cuppingModel.cupping.form != nil {
                    Section {
                        Button("Delete", role: .destructive) {
                            confirmDeleteAction = true
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if cuppingModel.cupping.form == nil {
                            cuppingModel.settingsSheetIsPresented = false
                            presentationMode.wrappedValue.dismiss()
                            
                            moc.delete(cuppingModel.cupping)
                            try? moc.save()
                        } else {
                            moc.rollback()
                            cuppingModel.settingsSheetIsPresented = false
                        }
                    }
                }
                
                StopwatchToolbarItem(placement: .principal)
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if cuppingModel.cupping.form == nil {
                        Button("Save") {
                            cuppingModel.cupping.form = CFManager().getDefaultCuppingForm(from: cuppingForms)
                            try? moc.save()
                            cuppingModel.settingsSheetDissmissDisabled = false
                            cuppingModel.settingsSheetIsPresented = false
                        }
                    } else {
                        Button("Done") { cuppingModel.settingsSheetIsPresented = false }
                    }
                }
            }
            .confirmationDialog(
                "Are you sure you want to delete cupping and all relative samples?",
                isPresented: $confirmDeleteAction,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    confirmDeleteAction = false
                    cuppingModel.settingsSheetIsPresented = false
                    presentationMode.wrappedValue.dismiss()
                    
                    moc.delete(cuppingModel.cupping)
                    try? moc.save()
                }
            }
        }
    }
}
