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
    
    let elementSize: CGFloat = BottomSheetConfiguration.QCGroup.elementSize
    
    var body: some View {
        ZStack {
            let firstSliderQC: QualityCriteria? = qcGroup.qualityCriteria.first(where: {
                $0.configuration.unwrappedEvaluation is SliderEvaluation
            })
            
            if let firstSliderQC {
                CircularQCGroupProgressView(criteria: firstSliderQC)
                    .frame(width: elementSize, height: elementSize)
                
//                Text(String(format: "%.2f", firstSliderQC.formattedValue))
            } else {
                Circle()
                    .frame(width: elementSize, height: elementSize)
                    .foregroundStyle(.gray.opacity(0.5))
            }
            
            Text(qcGroup.configuration.title.prefix(2))
        }
    }
    
    struct CircularQCGroupProgressView: View {
        @ObservedObject var criteria: QualityCriteria
        
        private let width: CGFloat = 2
        
        var body: some View {
            let upperBound: CGFloat = criteria.configuration.upperBound
            let lowerBound: CGFloat = criteria.configuration.lowerBound
            let value: CGFloat = criteria.value
            
            CircularProgressView(progress: (value - lowerBound) / (upperBound - lowerBound))
                .animation(.smooth, value: criteria.value)
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
