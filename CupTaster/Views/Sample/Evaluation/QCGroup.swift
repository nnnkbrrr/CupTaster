//
//  Criteria Group.swift
//  CupTaster
//
//  Created by Никита Баранов on 26.07.2023.
//

import SwiftUI

struct QCGroupView: View {
    @State var qcGroup: QCGroup
    
    var body: some View {
        VStack {
            let firstQCValue: String = {
                if let firstCriteria: QualityCriteria = qcGroup.qualityCriteria.sorted().first {
                    return String(format: "%.2f", firstCriteria.formattedValue)
                }
                return "-.--"
            }()
            
            HStack {
                Text(firstQCValue)
                    .font(.largeTitle)
                    .fontWeight(.light)
                
                VStack(alignment: .leading) {
                    Text(qcGroup.configuration.title)
                        .foregroundStyle(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            ForEach(qcGroup.sortedQualityCriteria) { criteria in
                
                if let criteriaConfig: QCConfig = criteria.configuration {
//                    criteriaConfig.unwrappedEvaluation
                    Text(criteriaConfig.title)
                }
            }
        }
        .padding(.small)
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius()
    }
}
