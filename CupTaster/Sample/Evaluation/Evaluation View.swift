//
//  EvaluationView.swift
//  CupTaster
//
//  Created by Никита on 19.07.2022.
//

import SwiftUI
import CoreData

struct EvaluationView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var qualityCriteria: QualityCriteria
    
    var body: some View {
        VStack {
            Text(qualityCriteria.title)
                .padding(.leading, 5)
                .font(.caption2)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let qcConfig = qualityCriteria.configuration {
                switch qcConfig.evaluationType.unwrappedEvaluationType {
                    case .slider:
                        SliderView(
                            value: $qualityCriteria.value,
                            configuration: qcConfig.sliderConfiguration
                        )
                    case .checkboxes:
                        CheckboxesView(
                            value: $qualityCriteria.value,
                            cuppingCupsCount: Int(qualityCriteria.group.sample.cupping.cupsCount)
                        )
                    case .radio:
                        RadioView(
                            value: $qualityCriteria.value,
                            lowerBound: qcConfig.lowerBound,
                            upperBound: qcConfig.upperBound,
                            step: qcConfig.step
                        )
                    case .none:
                        EmptyView()
                            .frame(height: 40)
                }
            }
        }
        .onChange(of: qualityCriteria.value) { _ in
            try? moc.save()
        }
    }
}
