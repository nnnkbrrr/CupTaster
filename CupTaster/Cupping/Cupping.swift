//
//  CuppingFolderView.swift
//  CupTaster
//
//  Created by Никита on 02.07.2022.
//

import SwiftUI
import CoreData
import UIKit

struct CuppingView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var moc
    
    @ObservedObject var cuppingModel: CuppingModel
    @FetchRequest var samples: FetchedResults<Sample>
    
    @Namespace var namespace
    @FocusState var notesTextEditorFocused: Bool
    
    init(cupping: Cupping) {
        self.cuppingModel = CuppingModel(cupping: cupping)
        self._samples = FetchRequest(
            entity: Sample.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Sample.ordinalNumber, ascending: true)],
            predicate: NSPredicate(format: "cupping == %@", cupping)
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                if cuppingModel.selectedSample == nil {
                    ScrollView {
                        VStack {
                            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                                ForEach(samples) { sample in
                                    Button {
                                        withAnimation {
                                            cuppingModel.selectedSample = sample
                                            cuppingModel.selectedSampleIndex = cuppingModel.sortedSamples.firstIndex(of: sample)!
                                            cuppingModel.samplesAppearance = .criteria
                                        }
                                    } label: {
                                        SampleView(cuppingModel: cuppingModel, sample: sample, appearance: .preview)
                                    }
                                    .matchedGeometryEffect(id: sample.id, in: namespace)
                                }
                            }
                            .padding()
                            
                            Divider()
                            
                            ZStack {
                                if cuppingModel.cupping.notes == "" {
                                    Text("Add notes")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .onTapGesture { notesTextEditorFocused = true }
                                }
                                
                                TextEditor(text: $cuppingModel.cupping.notes)
                                    .focused($notesTextEditorFocused)
                                    .frame(height: cuppingModel.cupping.notes == "" && !notesTextEditorFocused ? 0 : nil)
                                    .submitLabel(.done)
                                    .onSubmit { try? moc.save() }
                                    .onChange(of: cuppingModel.cupping.notes) { text in
                                        if !text.filter({ $0.isNewline }).isEmpty {
                                            cuppingModel.cupping.notes.removeLast()
                                            notesTextEditorFocused = false
                                        }
                                    }
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 35)
                            .animation(.default, value: notesTextEditorFocused)
                        }
                        .padding(.vertical)
                        .padding(.bottom, 50) // toolbar
                    }
                } else {
                    SampleSelectorView(cuppingModel: cuppingModel, namespace: namespace)
                }
                
                if !notesTextEditorFocused {
                    CuppingToolbarView(presentationMode: _presentationMode, cuppingModel: cuppingModel, namespace: namespace)
                }
            }
        }
        .halfSheet(
            isPresented: $cuppingModel.settingsSheetIsPresented,
            interactiveDismissDisabled: $cuppingModel.settingsSheetDissmissDisabled
        ) {
            CuppingSettingsView(presentationMode: _presentationMode, cuppingModel: cuppingModel)
        }
    }
}
