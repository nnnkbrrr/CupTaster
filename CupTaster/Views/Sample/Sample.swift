//
//  SampleView.swift
//  CupTaster
//
//  Created by Никита on 27.06.2022.
//

import SwiftUI

private struct DisableScrollBounceModifier: ViewModifier {
    init() { UIScrollView.appearance().bounces = false }
    func body(content: Content) -> some View { return content }
}

struct SampleView: View {
    @Environment(\.managedObjectContext) private var moc
    @State var sample: Sample
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(
                    sample.qualityCriteriaGroups
                        .sorted(by: { $0.configuration.ordinalNumber < $1.configuration.ordinalNumber })
                ) { qcGroup in
                    QCGroupView(qcGroup: qcGroup)
                }
            }
            .resignKeyboardOnDragGesture()
        }
    }
}

struct QCGroupView: View {
    @Environment(\.managedObjectContext) private var moc
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
                .background(qcGroup.isCompleted ? Color.clear : Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(10)
            
            if !qcGroup.isCompleted {
                VStack(spacing: 15) {
                    ForEach(qcGroup.qualityCriteria.sorted()) { qualityCriteria in
                        EvaluationView(qualityCriteria: qualityCriteria)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
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
                    .background(qcGroup.isCompleted ? Color.clear : Color(uiColor: .secondarySystemGroupedBackground))
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
//        .background(qcGroup.isCompleted ? Color(uiColor: .secondarySystemGroupedBackground) : Color.clear)
    }
}
