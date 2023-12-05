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
                .foregroundColor(.black)
                .frame(width: elementSize, height: elementSize)
            
            var score: Double {
                let formula: String = qcGroup.configuration.scoreFormula
                let expression = NSExpression(format: formula)
                let values: [String: Double] = {
                    let criteria: [QualityCriteria] = qcGroup.sortedQualityCriteria
                    
                    var dictionary: [String: Double] = Dictionary(uniqueKeysWithValues: criteria.map { criteria in
                        ("criteria_\(criteria.configuration.ordinalNumber)", Double(criteria.formattedValue))
                    })
                    
                    dictionary.updateValue(Double(qcGroup.sample.cupping.cupsCount), forKey: "cups_count")
                    return dictionary
                }()
                let expressionValue = expression.expressionValue(with: values, context: nil)
                return expressionValue as? Double ?? 0
            }
            
            if samplesControllerModel.selectedQCGroup == qcGroup {
                QCGroupValueView(qcGroup: qcGroup, score: $score)
                    .transition(.identity)
            } else {
                Text(String(qcGroup.configuration.title.prefix(2)))
                    .font(.caption)
                    .transition(.identity)
            }
        }
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    if samplesControllerModel.selectedQCGroup == qcGroup && qcGroup.isCompleted {
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
                .animation(.smooth, value: score)
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
                        criteria.group.isCompleted = true
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
            .onChange(of: criteria.value) { _ in try? moc.save() }
    }
}
