//
//  Cupping settings.swift
//  CupTaster
//
//  Created by Никита on 26.09.2022.
//

import SwiftUI
import CoreData

struct CuppingSettingsView: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(entity: CuppingForm.entity(), sortDescriptors: []) var cuppingForms: FetchedResults<CuppingForm>
    @ObservedObject var cuppingModel: CuppingModel
    
    @State var selectedCuppingForm: CuppingForm
    @State var selectedSamplesCount: Int = 1
    @State var selectedCupsCount: Int = 5
    
    var body: some View {
        NavigationView {
            Form {
                Section("Cupping name") {
                    TextField("Cupping name", text: $cuppingModel.cupping.name)
                        .submitLabel(.done)
                        .onSubmit { try? moc.save() }
                }
                
                Section("General Information") {
                    Picker("Samples count", selection: $selectedSamplesCount) {
                        ForEach(1...20, id: \.self) { samplesCount in
                            Text("\(samplesCount)").tag(samplesCount)
                        }
                    }
                    
                    Picker("Cups per sample", selection: $selectedCupsCount) {
                        ForEach(1...5, id: \.self) { cupsCount in
                            Text("\(cupsCount)").tag(cupsCount)
                        }
                    }
                    
                    Picker("Cupping Form", selection: $selectedCuppingForm) {
                        ForEach(cuppingForms) { cuppingForm in
                            Text(
                                cuppingForm.isDeprecated ?
                                "\(cuppingForm.shortDescription) (deprecated)" : cuppingForm.title
                            )
                            .tag(cuppingForm)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        cuppingModel.settingsSheetIsPresented = false
                        presentationMode.wrappedValue.dismiss()
                        
                        moc.delete(cuppingModel.cupping)
                        try? moc.save()
                    }
                }
                
                StopwatchToolbarItem(placement: .principal)
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        cuppingModel.cupping.cupsCount = Int16(selectedCupsCount)
                        cuppingModel.cupping.form = selectedCuppingForm
                        
                        for _ in 1...selectedCupsCount {
                            let usedNames: [String] = cuppingModel.cupping.samples.map { $0.name }
                            let defaultName: String = SampleNameGenerator().generateSampleDefaultName(usedNames: usedNames)
                            
                            let sample: Sample = Sample(context: moc)
                            
                            sample.name = defaultName
                            sample.ordinalNumber = Int16(cuppingModel.cupping.samples.count)
                            
                            if let cuppingForm = cuppingModel.cupping.form {
                                for groupConfig in cuppingForm.qcGroupConfigurations {
                                    let qcGroup: QCGroup = QCGroup(context: moc)
                                    qcGroup.sample = sample
                                    qcGroup.configuration = groupConfig
                                    for qcConfig in groupConfig.qcConfigurations {
                                        let qualityCriteria = QualityCriteria(context: moc)
                                        qualityCriteria.title = qcConfig.title
                                        qualityCriteria.value = qcConfig.value
                                        qualityCriteria.group = qcGroup
                                        qualityCriteria.configuration = qcConfig
                                    }
                                }
                            }
                            
                            cuppingModel.cupping.addToSamples(sample)
                        }
                        
                        try? moc.save()
                        
                        cuppingModel.selectedSample = cuppingModel.sortedSamples.first
                        cuppingModel.selectedSampleIndex = 0
                        cuppingModel.samplesAppearance = .criteria
                        
                        cuppingModel.settingsSheetDissmissDisabled = false
                        cuppingModel.settingsSheetIsPresented = false
                    }
                }
            }
        }
    }
}
