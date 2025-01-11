//
//  Sample Checkboxes Section.swift
//  CupTaster
//
//  Created by Никита Баранов on 08.12.2023.
//

import SwiftUI

extension SampleView {
    struct CheckboxesSummarySection: View {
        @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
        
        var body: some View {
            VStack {
                if let cupping: Cupping = samplesControllerModel.cupping, let form: CuppingForm = cupping.form, cupping.cupsCount > 1 {
                    var checkboxesCriteria: [QualityCriteria] {
                        if let sample: Sample = samplesControllerModel.selectedSample {
                            sample.sortedQCGroups
                                .flatMap { $0.sortedQualityCriteria }
                                .filter { $0.configuration.unwrappedEvaluation is CupsCheckboxesEvaluation }
                        } else {
                            form.qcGroupConfigurations
                                .sorted { $0.ordinalNumber < $1.ordinalNumber }
                                .flatMap { $0.qcConfigurations }
                                .filter { $0.unwrappedEvaluation is CupsCheckboxesEvaluation }
                        }
                    }

                    HStack(spacing: .extraSmall) {
                        ForEach(checkboxesCriteria) { criteria in
                            CheckboxesSummaryColumn(criteria: criteria, cupsCount: cupping.cupsCount)
                        }
                    }
                } else {
                    Text("Checkboxes summary is unavailable for cuppings with 1 cup per sample")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.gray)
                }
            }
            .padding(.small)
        }
        
        struct CheckboxesSummaryColumn: View {
            @ObservedObject var criteria: QualityCriteria
            let cupsCount: Int16
            
            var body: some View {
                VStack(spacing: .extraSmall) {
                    Text(criteria.group.configuration.shortLabel)
                        .resizableText(initialSize: 12)
                        .lineLimit(1)
                        .padding(.vertical, .extraSmall)
                    
                    let values: [Bool] = CupsCheckboxesEvaluation.checkboxesValues(value: criteria.value, cupsCount: cupsCount)
                    
                    ForEach(0..<Int(cupsCount), id: \.self) { index in
                        ZStack {
                            Capsule()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .foregroundStyle(Color.backgroundTertiary)
                                .zIndex(1.1)
                            
                            if values[safe: index] ?? false {
                                Capsule()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .foregroundStyle(Color.accentColor)
                                    .transition(.scale)
                                    .zIndex(1.2)
                            }
                        }
                        .animation(.smooth, value: criteria.value)
                    }
                }
            }
        }
    }
}

