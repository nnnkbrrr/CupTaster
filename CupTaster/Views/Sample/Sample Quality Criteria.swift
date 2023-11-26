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
    
    static let elementSize: CGFloat = .smallElement
    
    var body: some View {
        ZStack {
            let firstSliderQC: QualityCriteria? = qcGroup.qualityCriteria.first(where: {
                $0.configuration.unwrappedEvaluation is SliderEvaluation
            })
            
            if let firstSliderQC {
                let upperBound: CGFloat = firstSliderQC.configuration.upperBound
                let lowerBound: CGFloat = firstSliderQC.configuration.lowerBound
                let value: CGFloat = firstSliderQC.value
                
                CircularProgressView(progress: (value - lowerBound) / (upperBound - lowerBound))
                    .frame(width: .smallElement, height: .smallElement)
                    .id(qcGroup.configuration.id)
                
//                Text(String(format: "%.2f", firstSliderQC.formattedValue))
            } else {
                Circle()
                    .frame(width: Self.elementSize, height: Self.elementSize)
                    .foregroundStyle(.gray.opacity(0.5))
            }
            
            Text(qcGroup.configuration.title.prefix(2))
        }
        .id(qcGroup.configuration.id)
    }
    
    struct CircularProgressView: View {
        let progress: CGFloat
        let width: CGFloat = 2

        var body: some View {
            ZStack {
                Circle()
                    .stroke(lineWidth: width)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                    .padding(1)

                Circle()
                    .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.accentColor)
                    .rotationEffect(Angle(degrees: 270.0))
                    .padding(1)
            }
        }
    }
}

//struct QCGroupView: View {
//    @ObservedObject var qcGroup: QCGroup
//    
//    var body: some View {
//        VStack(spacing: .small) {
//            let qualityCriteria = qcGroup.sortedQualityCriteria
//            
//            HStack {
//                if let firstQC: QualityCriteria = qualityCriteria.first {
//                    QCGroupHeaderView(criteria: firstQC)
//                }
//                
//                VStack(alignment: .leading) {
//                    Text(qcGroup.configuration.title)
//                        .foregroundStyle(.gray)
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            
//            ForEach(Array(qualityCriteria.enumerated()), id: \.offset) { index, criteria in
//                QualityCriteriaView(criteria: criteria)
//                
//                if index + 1 != qualityCriteria.count {
//                    Divider()
//                }
//            }
//        }
//        .padding(.small)
//        .background(Color.secondarySystemGroupedBackground)
//        .cornerRadius()
//    }
//    
//    struct QCGroupHeaderView: View {
//        @ObservedObject var criteria: QualityCriteria
//        
//        var body: some View {
//            Text(String(format: "%.2f", criteria.formattedValue))
//                .font(.largeTitle)
//                .fontWeight(.light)
//        }
//    }
//
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
//}
