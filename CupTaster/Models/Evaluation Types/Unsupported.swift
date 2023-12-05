//
//  Unsupported.swift
//  CupTaster
//
//  Created by Никита Баранов on 27.07.2023.
//

import SwiftUI

class UnsupportedEvaluation: Evaluation {
    let name: String = "Unsupported"
    let sortOrder: Int = Int.max
    
    func getEvaluationValue(_ value: CGFloat, cupsCount: Int16 = 0) -> CGFloat { return 0 }
    
    func body(for criteria: QualityCriteria, value: Binding<Double>) -> some View {
        VStack(alignment: .leading) {
            Text("Unsupported Quality Criteria")
            Text("This cupping has a deprecated cupping form. Some of the quality criteria might not be displayed.")
                .foregroundStyle(.gray)
        }
        .font(.caption)
        .padding(.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundSecondary)
        .cornerRadius(.extraSmall)
    }
}
