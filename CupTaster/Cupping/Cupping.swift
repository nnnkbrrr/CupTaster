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
    
    init(cuppingModel: CuppingModel) {
        self.cuppingModel = cuppingModel
        self._samples = FetchRequest(
            entity: Sample.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Sample.ordinalNumber, ascending: true)],
            predicate: NSPredicate(format: "cupping == %@", cuppingModel.cupping)
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if cuppingModel.selectedSample == nil {
                    if cuppingModel.samplesEditorActive {
                        Form {
                            Section {
                                TextField("Cupping name", text: $cuppingModel.cupping.name)
                            }
                            
                            Section {
                                ForEach(samples) { sample in
                                    SampleFormRowView(sample: sample)
                                }
                                .onMove { indexSet, offset in
                                    var revisedItems: [Sample] = cuppingModel.sortedSamples
                                    revisedItems.move(fromOffsets: indexSet, toOffset: offset)
                                    
                                    for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
                                        revisedItems[reverseIndex].ordinalNumber = Int16(reverseIndex)
                                    }
                                }
                                .onDelete { offsets in
                                    for index in offsets {
                                        moc.delete(samples[index])
                                    }
                                }
                            }
                            
                            Section {
                                Button {
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
                                } label: {
                                    Label("Add sample", systemImage: "plus")
                                }
                            }
                        }
                        .environment(\.editMode, .constant(.active))
                        .padding(.bottom, 44) // toolbar
                        .resignKeyboardOnDragGesture() { try? moc.save() }
                    } else {
                        ScrollView {
                            Text(cuppingModel.cupping.name)
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding([.top, .horizontal], 20)
                            
                            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                                ForEach(samples) { sample in
                                    Button {
                                        withAnimation {
                                            cuppingModel.selectedSample = sample
                                            cuppingModel.selectedSampleIndex = cuppingModel.sortedSamples.firstIndex(of: sample)!
                                            cuppingModel.samplesAppearance = .criteria
                                        }
                                    } label: {
                                        SampleView(cuppingModel: cuppingModel, sample: sample).preview
                                    }
                                    .matchedGeometryEffect(id: sample.id, in: namespace)
                                }
                            }
                            .padding([.bottom, .horizontal])
                            .padding(.bottom, 44) // toolbar
                        }
                    }
                } else {
                    SampleSelectorView(cuppingModel: cuppingModel, namespace: namespace)
                }
                
                VStack {
                    Rectangle()
                        .foregroundColor(Color(uiColor: .systemBackground))
                        .frame(height: 15 + geometry.safeAreaInsets.top)
                        .mask {
                            VStack(spacing: 0) {
                                LinearGradient(
                                    colors: [Color.black.opacity(0), Color.black],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                                .frame(height: 15 + geometry.safeAreaInsets.top)
                            }
                        }
                    
                    Spacer()
                    
                    CuppingToolbarView(presentationMode: _presentationMode, cuppingModel: cuppingModel, namespace: namespace)
                }
                .edgesIgnoringSafeArea(.top)
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
