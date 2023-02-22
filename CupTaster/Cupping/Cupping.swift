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
            if cuppingModel.sampleViewVisible {
                SampleSelectorView(cuppingModel: cuppingModel, namespace: namespace)
                    .zIndex(1)
                    .clipped()
            } else if cuppingModel.samplesEditorActive {
                Form {
                    Section {
                        TextField("Cupping name", text: $cuppingModel.cupping.name)
                    }
										
                    if showCuppingsDatePicker {
                        Section {
                            DatePicker("Date:", selection: $cuppingModel.cupping.date, displayedComponents: [.date])
                        }
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
                .clipped()
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
                                cuppingModel.selectedSample = sample
                                cuppingModel.selectedSampleIndex = cuppingModel.sortedSamples.firstIndex(of: sample)!
                                cuppingModel.samplesAppearance = .criteria
                                cuppingModel.offset = .zero
                                cuppingModel.switchingToPreviews = false
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                    withAnimation {
                                        cuppingModel.sampleViewVisible = true
                                    }
                                }
                            } label: {
                                SampleView(cuppingModel: cuppingModel, sample: sample).preview
                            }
                            .matchedGeometryEffect(id: sample.id, in: namespace)
                            .zIndex(cuppingModel.selectedSample?.id == sample.id ? 1 : 0)
                        }
                    }
                    .padding([.bottom, .horizontal])
                    .padding(.bottom, 44) // toolbar
                }
                .clipped()
            }
            
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
            
            if let qcGroupConfig = cuppingModel.selectedHintsQCGConfig {
                ScrollView(showsIndicators: false) {
                    HintsMenuView(qcGroupConfig: qcGroupConfig)
                        .padding(50)
                }
                .background(.ultraThinMaterial)
                .safeAreaInset(edge: .bottom) {
                    Button {
                        withAnimation {
                            cuppingModel.selectedHintsQCGConfig = nil
                        }
                    } label: {
                        Text("Done")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .cornerRadius(15)
                            .shadow(radius: 15)
                            .padding([.horizontal, .bottom], 50)
                    }
                }
                .transition(.move(edge: .bottom))
                .zIndex(3)
            }
            
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
