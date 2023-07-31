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
        VStack(spacing: .small) {
            let qualityCriteria = qcGroup.sortedQualityCriteria
            
            HStack {
                if let firstQC: QualityCriteria = qualityCriteria.first {
                    QCGroupHeaderView(criteria: firstQC)
                }
                
                VStack(alignment: .leading) {
                    Text(qcGroup.configuration.title)
                        .foregroundStyle(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            ForEach(Array(qualityCriteria.enumerated()), id: \.offset) { index, criteria in
                QualityCriteriaView(criteria: criteria)
                
                if index + 1 != qualityCriteria.count {
                    Divider()
                }
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
        @Environment(\.managedObjectContext) private var moc
        @ObservedObject var criteria: QualityCriteria
        
        var body: some View {
            VStack {
                let title = criteria.title
                if title != criteria.group.configuration.title {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                
                AnyView(criteria.configuration.unwrappedEvaluation.body(for: criteria, value: $criteria.value))
            }
            .onChange(of: criteria.value) { _ in try? moc.save() }
        }
    }
}
