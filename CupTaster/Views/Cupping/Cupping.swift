//
//  CuppingFolderView.swift
//  CupTaster
//
//  Created by Никита on 02.07.2022.
//

import SwiftUI
import CoreData

struct CuppingView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var cupping: Cupping
    
    @FocusState var notesTextEditorActive: Bool
    @FetchRequest(
        entity: CuppingForm.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CuppingForm.title, ascending: true)]
    ) var cuppingForms: FetchedResults<CuppingForm>
    
    var body: some View {
        ScrollView {
            LazyVStack {
                InsetFormSection {
                    TextField("", text: $cupping.name)
                        .submitLabel(.done)
                        .onSubmit { try? moc.save() }
                } header: {
                    HStack {
                        Text("Cupping Name")
                        Spacer()
                        if cupping.notes == "" {
                            Button("Notes") {
                                notesTextEditorActive = true
                            }
                            .transition(.opacity)
                        }
                    }
                    .animation(.default, value: cupping.notes)
                }
                
                TextEditor(text: $cupping.notes)
                    .textEditorBackgroundColor(.clear)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 35)
                    .focused($notesTextEditorActive)
                    .frame(height: cupping.notes == "" && !notesTextEditorActive ? 0 : nil)
                    .submitLabel(.done)
                    .onSubmit { try? moc.save() }
                    .onChange(of: cupping.notes) { text in
                        if !text.filter({ $0.isNewline }).isEmpty {
                            cupping.notes.removeLast()
                            notesTextEditorActive = false
                        }
                    }
                
                InsetFormSection("General Information") {
                    DatePicker("Date", selection: $cupping.date, displayedComponents: [.date])
                    
#warning("pick cupping form")
                    HStack {
                        Text("Cupping form")
                        Spacer()
                        Picker("", selection: $cupping.form) {
                            Text("SCA").tag(cupping.form)
                        }
                        .pickerStyle(MenuPickerStyle())
                        .labelsHidden()
                        .background(Color(uiColor: .systemGray5), in: RoundedRectangle(cornerRadius: 10))
                    }
                    
                    HStack {
                        Text("Cups count")
                        Spacer()
                        Picker("", selection: $cupping.cupsCount) {
                            ForEach(1...5, id: \.self) { cupsCout in
                                Text("\(cupsCout)").tag(Int16(cupsCout))
                            }
                        }
                        .labelsHidden()
                        .background(Color(uiColor: .systemGray5), in: RoundedRectangle(cornerRadius: 10))
#warning("select cups count")
                    }
                }
                .disabled(cupping.form != nil)
                
                if cupping.form == nil {
                    InsetFormSection("Finish setting up") {
                        Button {
                            cupping.form = CuppingFormsModel().getCurrentCuppingForm(cuppingForms: cuppingForms)
                            try? moc.save()
                        } label: {
                            Text("Done")
                        }
                        .buttonStyle(InsetFormButtonStyle())
                    }
                } else {
                    CuppingSamplesView(cupping: cupping)
                }
            }
            .padding(.bottom)
            .animation(.default, value: cupping.samples)
            .animation(.default, value: cupping.form)
            .animation(.default, value: notesTextEditorActive)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarTitle(cupping.name, displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(" ")
            }
            
            StopwatchToolbarItem()
        }
    }
    
    public var preview: some View {
        NavigationLink(destination: self) {
            VStack(alignment: .leading) {
                Text(cupping.name)
                Text(cupping.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 5)
        }
    }
}
