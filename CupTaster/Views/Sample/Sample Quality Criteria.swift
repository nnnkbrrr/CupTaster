//
//  Criteria Group.swift
//  CupTaster
//
//  Created by Никита Баранов on 26.07.2023.
//

import SwiftUI

struct QCGroupView: View {
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    @ObservedObject var qcGroup: QCGroup
    @State var score: Double
    
    init(qcGroup: QCGroup) {
        self.qcGroup = qcGroup
        self.score = qcGroup.score
    }
    
    let elementSize: CGFloat = SampleBottomSheetConfiguration.QCGroup.elementSize
    
    var body: some View {
        ZStack {
            CircularQCGroupProgressView(qcGroup: qcGroup, score: $score)
                .frame(width: elementSize, height: elementSize)
            
            if samplesControllerModel.selectedQCGroup == qcGroup {
                QCGroupValueView(qcGroup: qcGroup, score: $score)
                    .frame(maxWidth: .infinity)
                    .matchedGeometryEffect(id: qcGroup.id, in: NamespaceControllerModel.shared.namespace)
            } else {
                Text(String(qcGroup.configuration.title.prefix(2)))
                    .frame(maxWidth: .infinity)
                    .matchedGeometryEffect(id: qcGroup.id, in: NamespaceControllerModel.shared.namespace)
                    .font(.caption)
            }
        }
        .animation(.easeInOut, value: samplesControllerModel.selectedSample)
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    guard samplesControllerModel.selectedQCGroup == qcGroup else { return }
                    if qcGroup.isCompleted {
                        for criteria in qcGroup.qualityCriteria {
                            criteria.value = criteria.configuration.value
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            qcGroup.isCompleted = false
                        }
                    } else {
                        qcGroup.isCompleted = true
                    }
                }
        )
    }
    
    struct CircularQCGroupProgressView: View {
        @ObservedObject var qcGroup: QCGroup
        @Binding var score: Double
        let upperBound: CGFloat
        let lowerBound: CGFloat
        
        init(qcGroup: QCGroup, score: Binding<Double>) {
            self.qcGroup = qcGroup
            self._score = score
            self.upperBound = qcGroup.configuration.scoreUpperBound
            self.lowerBound = qcGroup.configuration.scoreLowerBound
        }
        
        private let width: CGFloat = 2
        
        var body: some View {
            ZStack {
                Circle()
                    .foregroundStyle(Color.backgroundTertiary)
                
                CircularProgressView(
                    progress: (score - lowerBound) / (upperBound - lowerBound),
                    progressColor: qcGroup.isCompleted ? .accentColor : .gray
                )
                .animation(.default, value: score)
            }
        }
    }
    
    struct QCGroupValueView: View {
        @ObservedObject var qcGroup: QCGroup
        @Binding var score: Double
        
        var body: some View {
            ZStack {
                ForEach(qcGroup.sortedQualityCriteria) { criteria in
                    ScoreUpdater(criteria: criteria, score: $score)
                }
                
                Text(String(format: "%.2f", score))
                    .font(.caption)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        
        struct ScoreUpdater: View {
            @ObservedObject var criteria: QualityCriteria
            @Binding var score: Double
            
            var body: some View {
                EmptyView()
                    .onChange(of: criteria.value) { _ in
                        score = criteria.group.score
                    }
            }
        }
    }
}

struct QualityCriteriaView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var criteria: QualityCriteria
    
    var body: some View {
        AnyView(criteria.configuration.unwrappedEvaluation.body(for: criteria, value: $criteria.value))
            .onChange(of: criteria.value) { _ in
                criteria.group.isCompleted = true
                criteria.group.sample.calculateFinalScore()
                save(moc)
            }
    }
}
