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
    @Environment(\.managedObjectContext) var moc
    @Namespace var namespace
    
    @FetchRequest(entity: CuppingForm.entity(), sortDescriptors: []) var cuppingForms: FetchedResults<CuppingForm>
    
    @ObservedObject var cuppingModel: CuppingModel
    @FetchRequest var samples: FetchedResults<Sample>
    
    @FocusState var sampleNameTextfieldFocus: ObjectIdentifier?
		
    @AppStorage("tester-show-cuppings-date-picker") var showCuppingsDatePicker: Bool = false
    
    init(cuppingModel: CuppingModel) {
        self.cuppingModel = cuppingModel
        self._samples = FetchRequest(
            entity: Sample.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Sample.ordinalNumber, ascending: true)],
            predicate: NSPredicate(format: "cupping == %@", cuppingModel.cupping)
        )
    }
    
    var body: some View {
        ZStack {
            if cuppingModel.sampleViewVisible { SampleSelectorView(cuppingModel: cuppingModel, namespace: namespace) }
			else if cuppingModel.samplesEditorActive { samplesEditor }
			else { samplesPreview }
            
            CuppingToolbarView(
                presentationMode: _presentationMode,
                cuppingModel: cuppingModel,
                namespace: namespace,
                sampleNameTextfieldFocus: _sampleNameTextfieldFocus
            )
            .overlay(alignment: .top) {
                Rectangle()
                    .foregroundColor(.gray)
                    .opacity(0.5)
                    .frame(height: 0.2)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea(.keyboard, edges: sampleNameTextfieldFocus == nil ? [.all] : [])
            .animation(.default, value: sampleNameTextfieldFocus)
            .zIndex(2)
			
			selectedHint
			
            LinearGradient(
                colors: [Color(uiColor: .systemGroupedBackground), Color(uiColor: .systemGroupedBackground).opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 15)
            .frame(maxHeight: .infinity, alignment: .top)
            .zIndex(4)
        }
        .halfSheet(
            isPresented: $cuppingModel.settingsSheetIsPresented,
            interactiveDismissDisabled: $cuppingModel.settingsSheetDismissDisabled
        ) {
            CuppingSettingsView(
                presentationMode: _presentationMode,
                cuppingModel: cuppingModel,
                selectedCuppingForm: CFManager.shared.getDefaultCuppingForm(from: cuppingForms)!
            )
        }
        .background(Color(uiColor: .systemGroupedBackground), ignoresSafeAreaEdges: .top)
        .background(
            Color.keyboardBackground
                .opacity(sampleNameTextfieldFocus == nil ? 0 : 1)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}
