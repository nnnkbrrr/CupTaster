//
//  Criteria Group.swift
//  CupTaster
//
//  Created by Никита Баранов on 26.07.2023.
//

import SwiftUI

struct QCGroupView: View {
    @ObservedObject var qcGroup: QCGroup
    
    var body: some View {
        VStack {
            HStack {
                if let firstQC: QualityCriteria = qcGroup.qualityCriteria.sorted().first {
                    QCGroupHeaderView(criteria: firstQC)
                }
                
                VStack(alignment: .leading) {
                    Text(qcGroup.configuration.title)
                        .foregroundStyle(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            ForEach(qcGroup.sortedQualityCriteria) { criteria in
                QualityCriteriaView(criteria: criteria)
            }
        }
        .padding(.small)
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius()
    }
    
    struct QCGroupHeaderView: View {
        @ObservedObject var criteria: QualityCriteria
        
        var body: some View {
            Text(String(format: "%.2f", criteria.formattedValue))
                .font(.largeTitle)
                .fontWeight(.light)
        }
    }

    struct QualityCriteriaView: View {
        @ObservedObject var criteria: QualityCriteria
        
        var body: some View {
            VStack {
                Text(criteria.configuration.title)
                AnyView(criteria.configuration.unwrappedEvaluation.body(value: $criteria.value, configuration: criteria.configuration))
            }
        }
    }
}
