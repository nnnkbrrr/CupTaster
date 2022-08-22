//
//  Evaluation Header View.swift
//  CupTaster
//
//  Created by Никита on 19.07.2022.
//

import SwiftUI

struct EvaluationHeaderView: View {
    @ObservedObject var qcGroup: QCGroup
    
    var body: some View {
        if let firstQualityCriteria: QualityCriteria = qcGroup.qualityCriteria.sorted().first,
           let qcCongifuration: QCConfig = firstQualityCriteria.configuration {
            ZStack {
                switch qcCongifuration.evaluationType.unwrappedEvaluationType {
                    case .slider:
                        SliderEvaluationHeaderView(qualityCriteria: firstQualityCriteria)
                    case .radio:
                        CheckboxesEvaluationHeaderView(qualityCriteria: firstQualityCriteria)
                    case .checkboxes:
                        CheckboxesEvaluationHeaderView(qualityCriteria: firstQualityCriteria)
                    case .none:
                        EmptyView()
                            .frame(height: 40)
                }
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
