//
//  Evaluation Group.swift
//  CupTaster
//
//  Created by Никита on 13.09.2022.
//

import SwiftUI

struct EvaluationGroupView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var cuppingModel: CuppingModel
    @ObservedObject var qcGroup: QCGroup
    
    var body: some View {
        VStack(spacing: 3) {
            if qcGroup.isCompleted {
                Capsule()
                    .foregroundColor(Color(uiColor: .systemGray5))
                    .frame(height: 0.5)
                    .padding(.bottom, 15)
            }
            
            EvaluationHeaderView(qcGroup: qcGroup, isCompleted: $qcGroup.isCompleted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, qcGroup.isCompleted ? 0 : 15)
                .background(qcGroup.isCompleted ? Color.clear : Color(uiColor: .systemGray6))
                .cornerRadius(10)
            
            if !qcGroup.isCompleted {
                VStack(spacing: 15) {
                    ForEach(qcGroup.qualityCriteria.sorted()) { qualityCriteria in
                        EvaluationView(cuppingModel: cuppingModel, qualityCriteria: qualityCriteria)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(10)
                .transition(
                    .scale(scale: 0, anchor: .top)
                    .combined(with: .opacity)
                )
            }
            
            if !qcGroup.isCompleted || qcGroup.notes != "" {
                TextField("Notes", text: $qcGroup.notes)
                    .font(.caption)
                    .opacity(qcGroup.isCompleted ? 0.5 : 1)
                    .padding(.vertical, qcGroup.isCompleted ? 0 : 15)
                    .padding(.horizontal, 20)
                    .background(qcGroup.isCompleted ? Color.clear : Color(uiColor: .systemGray6))
                    .cornerRadius(10)
                    .submitLabel(.done)
                    .onSubmit { try? moc.save() }
                    .transition(
                        .scale(scale: 0, anchor: .top)
                        .combined(with: .opacity)
                    )
                    .disabled(qcGroup.isCompleted)
            }
            
            if qcGroup.isCompleted {
                Capsule()
                    .foregroundColor(Color(uiColor: .systemGray5))
                    .frame(height: 0.5)
                    .padding(.top, 15)
            }
        }
        .padding(.vertical, qcGroup.isCompleted ? 0 : 15)
    }
}
