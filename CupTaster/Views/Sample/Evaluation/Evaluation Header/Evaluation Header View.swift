//
//  Evaluation Header View.swift
//  CupTaster
//
//  Created by Никита on 19.07.2022.
//

import SwiftUI

struct EvaluationHeaderView: View {
    @ObservedObject var qcGroup: QCGroup
    @Binding var isCompleted: Bool
    
    var body: some View {
        if let firstQualityCriteria: QualityCriteria = qcGroup.qualityCriteria.sorted().first,
           let qcConfiguration: QCConfig = firstQualityCriteria.configuration {
            HStack {
                ZStack {
                    switch qcConfiguration.evaluationType.unwrappedEvaluationType {
                        case .slider:
                            SliderEvaluationValueView(qualityCriteria: firstQualityCriteria)
                        case .radio:
                            CheckboxesEvaluationValueView(qualityCriteria: firstQualityCriteria)
                        case .checkboxes:
                            CheckboxesEvaluationValueView(qualityCriteria: firstQualityCriteria)
                        case .none:
                            EmptyView().frame(height: 40)
                    }
                }
                .scaleEffect(qcGroup.isCompleted ? 0.75 : 1)
                .padding(.vertical, 3)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(Capsule())
                
                Divider()
                Text(qcGroup.configuration.title).bold()
                qcRepresentations
                Spacer()
                Image(systemName: "chevron.right")
                    .rotationEffect(Angle(degrees: isCompleted ? 0 : 90))
                    .padding(.trailing)
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .animation(.spring(), value: isCompleted)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.interpolatingSpring(stiffness: 250, damping: 250)) {
                    isCompleted.toggle()
                    qcGroup.objectWillChange.send()
                }
            }
        }
    }
    
    var qcRepresentations: some View {
        VStack(alignment: .leading, spacing: 3) {
            let allQC: [QualityCriteria] =
            qcGroup.qualityCriteria.sorted()
            
            ForEach(allQC) { qualityCriteria in
                QCRepresentation(qualityCriteria: qualityCriteria)
            }
        }
        .padding(.leading, 5)
    }
}

struct QCRepresentation: View {
    @ObservedObject var qualityCriteria: QualityCriteria
    
    var body: some View {
        if let qcConfiguration: QCConfig = qualityCriteria.configuration {
            if qcConfiguration.evaluationType.unwrappedEvaluationType == .radio {
                HStack(spacing: 3) {
                    ForEach(
                        Array(stride(
                            from: qcConfiguration.lowerBound,
                            through: qcConfiguration.upperBound,
                            by: qcConfiguration.step
                        )),
                        id: \.self
                    ) { fractionValue in
                        Image(systemName: "circle" + (Int(qualityCriteria.value) >= Int(fractionValue) ? ".fill" : ""))
                            .resizable()
                            .frame(width: 6, height: 6)
                            .foregroundColor(.gray)
                    }
                }
                .animation(.spring(), value: qualityCriteria.value)
            }
            
            if qcConfiguration.evaluationType.unwrappedEvaluationType == .checkboxes {
                let qcStringValue: String = String(Int(qualityCriteria.value))
                let fullBinaryString: String = String(
                    repeating: "0",
                    count: Int(qualityCriteria.group.sample.cupping.cupsCount) - qcStringValue.count
                ) + qcStringValue
                let binaryArray: [Character] = Array(fullBinaryString)
                let checkboxValues: [(Int, Bool)] =
                Array(zip(binaryArray.indices, binaryArray.map { $0 == "1" }))
                
                HStack(spacing: 3) {
                    ForEach(checkboxValues, id: \.0) { _, checkboxMarked in
                        ZStack {
                            Image(systemName: "minus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 7, height: 7)
                                .rotationEffect(Angle(degrees: checkboxMarked ? -45 : 0))
                            Image(systemName: "minus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 7, height: 7)
                                .rotationEffect(Angle(degrees: checkboxMarked ? -135 : 0))
                        }
                    }
                }
                .animation(.spring(), value: qualityCriteria.value)
                .foregroundColor(.gray)
            }
        }
    }
}
