//
//  CuppingFolderView.swift
//  CupTaster
//
//  Created by Никита on 02.07.2022.
//

import SwiftUI
import CoreData

struct CuppingView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var moc
    @Namespace var namespace
    @ObservedObject var cupping: Cupping
    
    @FetchRequest( entity: CuppingForm.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \CuppingForm.title, ascending: true)])
    var cuppingForms: FetchedResults<CuppingForm>
    @FocusState var notesTextEditorFocused: Bool
    @State var selectedSample: Sample?
    
    @State private var confirmDeleteAction: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack {
                    InsetFormSection {
                        TextField("Cupping name", text: $cupping.name)
                            .submitLabel(.done)
                            .onSubmit { try? moc.save() }
                    } header: {
                        HStack {
                            ZStack {
                                if cupping.notes == "" {
                                    Button("Add Notes") {
                                        notesTextEditorFocused = true
                                    }
                                    .transition(.opacity)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Cupping")
                            
                            Button("Delete") { confirmDeleteAction = true }
                                .transition(.opacity)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .animation(.default, value: cupping.notes)
                    }
                    
                    TextEditor(text: $cupping.notes)
                        .textEditorBackgroundColor(.clear)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 35)
                        .focused($notesTextEditorFocused)
                        .frame(height: cupping.notes == "" && !notesTextEditorFocused ? 0 : nil)
                        .submitLabel(.done)
                        .onSubmit { try? moc.save() }
                        .onChange(of: cupping.notes) { text in
                            if !text.filter({ $0.isNewline }).isEmpty {
                                cupping.notes.removeLast()
                                notesTextEditorFocused = false
                            }
                        }
                    
                    if cupping.form == nil {
                        generalInformation
                        
                        InsetFormSection("Finish setting up") {
                            Button {
                                cupping.form = CFManager().getDefaultCuppingForm(from: cuppingForms)
                                try? moc.save()
                            } label: { Text("Done") }
                            .buttonStyle(InsetFormButtonStyle())
                        }
                    } else {
                        generalInformationCompact
                        if selectedSample == nil {
                            CuppingSamplesView(namespace: namespace, cupping: cupping, selectedSample: $selectedSample)
                        }
                    }
                }
                .padding(.vertical)
                .animation(.default, value: cupping.samples)
                .animation(.default, value: cupping.form)
                .animation(.default, value: notesTextEditorFocused)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .safeAreaInset(edge: .top) {
                HStack {
                    StopwatchView()
                    
                    Spacer()
                    
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Done")
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 10)
                .background(Color(uiColor: .systemGray6))
            }
            
            if selectedSample != nil {
                SampleSelectorView(cupping: cupping, selectedSample: $selectedSample, namespace: namespace)
                    .background(
                        .ultraThinMaterial,
                        ignoresSafeAreaEdges: .all
                    )
            }
        }
        .confirmationDialog(
            "Are you sure you want to delete cupping and all relative samples?",
            isPresented: $confirmDeleteAction,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                cupping.objectWillChange.send()
                moc.delete(cupping)
                try? moc.save()
            }
        }
    }
    
    private var generalInformation: some View {
        InsetFormSection("General Information") {
//            DatePicker("Date", selection: $cupping.date, in: ...Date(), displayedComponents: [.date])
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
                .disabled(true)
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
            }
        }
        .disabled(cupping.form != nil)
    }
    
    private var generalInformationCompact: some View {
        HStack(spacing: 5) {
            if let cuppingForm = cupping.form {
                let dateFormatter: DateFormatter = {
                    let formatter = DateFormatter()
                    formatter.doesRelativeDateFormatting = true
                    formatter.dateStyle = .short
                    return formatter
                }()
                
                Group {
                    Text(dateFormatter.string(from: cupping.date))
                        .padding(.horizontal, 10)
                        .frame(height: 44)
                        .background(
                            Color(uiColor: .secondarySystemGroupedBackground),
                            in: RoundedRectangle(cornerRadius: 10)
                        )
                    Text(cuppingForm.title)
                    Label("x  \(cupping.cupsCount)", systemImage: "cup.and.saucer")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    Color(uiColor: .secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 10)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}