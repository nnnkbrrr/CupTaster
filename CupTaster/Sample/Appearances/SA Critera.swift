//
//  SA Critera.swift
//  CupTaster
//
//  Created by Никита Баранов on 01.03.2023.
//

import SwiftUI

extension SampleView {
    var criteriaAppearance: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(
                    sample.qualityCriteriaGroups
                        .sorted(by: { $0.configuration.ordinalNumber < $1.configuration.ordinalNumber })
                ) { qcGroup in
                    EvaluationGroupView(cuppingModel: cuppingModel, qcGroup: qcGroup)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100) // toolbar
        }
        .clipped()
        .resignKeyboardOnDragGesture() { try? moc.save() }
    }
}
