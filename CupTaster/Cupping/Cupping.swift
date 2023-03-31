//
//  CuppingFolderView.swift
//  CupTaster
//
//  Created by Никита on 02.07.2022.
//

import SwiftUI
import CoreData

struct CuppingView: View, KeyboardReadable {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    @Namespace var namespace
    
    @FetchRequest(entity: CuppingForm.entity(), sortDescriptors: []) var cuppingForms: FetchedResults<CuppingForm>
    
    @ObservedObject var cuppingModel: CuppingModel
    @FetchRequest var samples: FetchedResults<Sample>
    
    @FocusState var sampleNameTextfieldFocus: ObjectIdentifier?
	@State var keyboardIsActive: Bool = false
		
    @AppStorage("tester-show-cuppings-date-picker") var showCuppingsDatePicker: Bool = false
    
    init(cuppingModel: CuppingModel) {
        self.cuppingModel = cuppingModel
        self._samples = FetchRequest(
            entity: Sample.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Sample.ordinalNumber, ascending: true)],
            predicate: NSPredicate(format: "cupping == %@", cuppingModel.cupping)
        )
    }
    
#warning("safe area keyboard avoidance")
	var body: some View {
		ZStack {
			if cuppingModel.sampleViewVisible { SampleSelectorView(cuppingModel: cuppingModel, namespace: namespace) }
			else if cuppingModel.samplesEditorActive { samplesEditor }
			else { samplesPreview }
			selectedHint
		}
		.safeAreaInset(edge: .top) {
			VStack(spacing: 0) {
				if cuppingModel.sampleViewVisible {
					if cuppingModel.samplesAppearance == .info, let selectedSample = cuppingModel.selectedSample {
						SampleInfoToolbar(cuppingModel: cuppingModel, sample: selectedSample)
					}
				} else if !cuppingModel.samplesEditorActive {
					Text(cuppingModel.cupping.name)
						.bold()
						.padding(10)
				}
				Divider()
			}
			.background(.ultraThinMaterial, ignoresSafeAreaEdges: .all)
			.background(Color.keyboardBackground.opacity(0.2), ignoresSafeAreaEdges: .all)
		}
		.safeAreaInset(edge: .bottom, spacing: 0) {
			if !keyboardIsActive || sampleNameTextfieldFocus != nil {
				CuppingToolbarView(
					presentationMode: _presentationMode,
					cuppingModel: cuppingModel,
					namespace: namespace,
					sampleNameTextfieldFocus: _sampleNameTextfieldFocus
				)
			}
		}
		.onReceive(keyboardPublisher) { keyboardIsActive = $0 }
		.background(Color(uiColor: .systemGroupedBackground), ignoresSafeAreaEdges: .all)
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
    }
}
