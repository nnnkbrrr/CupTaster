//
//  Cupping.swift
//  CupTaster
//
//  Created by Никита Баранов on 06.07.2023.
//

import SwiftUI
import CoreData

struct CuppingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    @ObservedObject var cupping: Cupping
    
    @State private var settingsModalIsActive: Bool = false
    
    init(_ cupping: Cupping) {
        self.cupping = cupping
    }
    
    var body: some View {
        Group {
            if cupping.samples.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        dismiss()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                moc.delete(cupping)
                                save(moc)
                            }
                        }
                    }
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(
                                .adaptive(minimum: 150, maximum: 200),
                                spacing: .extraSmall,
                                alignment: .top
                            )
                        ],
                        spacing: .extraSmall
                    ) {
                        let sortedSamples = cupping.sortedSamples
                        ForEach(sortedSamples) { sample in
                            SamplePreview(sample)
                        }
                    }
                    .padding(.small)
                }
            }
        }
        .background(Color.backgroundPrimary, ignoresSafeAreaEdges: .all)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    let showTemplate: Bool = cupping.name == ""
                    
                    Text(showTemplate ? "New Cupping" : cupping.name)
                        .multilineTextAlignment(.center)
                        .resizableText()
                        .foregroundStyle(showTemplate ? .gray : .primary)
                    
                    Image(systemName: "chevron.down.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: .regular, height: .regular)
                        .foregroundColor(.gray)
                }
                .frame(height: .large)
                .contentShape(Rectangle())
                .onTapGesture {
                    settingsModalIsActive = true
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let usedNames: [String] = cupping.samples.map { $0.name }
                    let defaultName: String = SampleNameGeneratorModel.generateSampleDefaultName(usedNames: usedNames)
                    
                    let sample: Sample = Sample(context: moc)
                    
                    sample.name = defaultName
                    sample.ordinalNumber = Int16(cupping.samples.count)
                    
                    if let cuppingForm = cupping.form {
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
                    
                    cupping.addToSamples(sample)
                    sample.calculateFinalScore()
                    
                    save(moc)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .defaultNavigationBar()
        .adaptiveSizeSheet(isPresented: $settingsModalIsActive) {
            CuppingSettingsView(
                cupping: cupping,
                isActive: $settingsModalIsActive,
                onDelete: {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            moc.delete(cupping)
                            save(moc)
                        }
                    }
                }
            )
        }
    }
}
