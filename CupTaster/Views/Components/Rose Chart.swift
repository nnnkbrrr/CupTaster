//
//  Rose Chart.swift
//  CupTaster
//
//  Created by Никита Баранов on 26.12.2023.
//

import SwiftUI

struct RoseChart: View {
    let qualityCriteria: [QualityCriteria]
    
    init(sample: Sample) {
        self.qualityCriteria = sample.qualityCriteriaGroups
            .sorted(by: { $0.configuration.ordinalNumber < $1.configuration.ordinalNumber })
            .flatMap { $0.qualityCriteria }
            .filter { $0.configuration.evaluationType.unwrappedEvaluation is SliderEvaluation }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                ForEach(Array(qualityCriteria.enumerated()), id: \.offset) { index, qualityCriteria in
                    RoseChartSegment(qualityCriteria: qualityCriteria, in: self.qualityCriteria)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1), value: qualityCriteria.value)
                }
                
                RoseChartGrid(categoriesCount: qualityCriteria.count, divisionsCount: 4)
                    .stroke(.gray, lineWidth: 0.5)
                
                RoseChartLabels(qualityCriteria: qualityCriteria, geometry: geometry)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fill)
    }
}

extension RoseChart {
    private struct RoseChartSegment: View {
        @ObservedObject var qcGroup: QCGroup
        @ObservedObject var qualityCriteria: QualityCriteria
        let allQualityCriteria: [QualityCriteria]
        
        init(qualityCriteria: QualityCriteria, in allQualityCriteria: [QualityCriteria]) {
            self.qualityCriteria = qualityCriteria
            self.qcGroup = qualityCriteria.group
            self.allQualityCriteria = allQualityCriteria
        }
        
        var body: some View {
            SegmentPath(
                value: qualityCriteria.value,
                criteriaCount: allQualityCriteria.count,
                index: allQualityCriteria.firstIndex(of: qualityCriteria) ?? 0,
                lowerBoundValue: qualityCriteria.configuration.lowerBound,
                upperBoundValue: qualityCriteria.configuration.upperBound
            )
            .foregroundColor(qcGroup.isCompleted ? Color.accentColor.opacity(0.5) : .backgroundTertiary)
            .animation(.bouncy, value: qualityCriteria.value)
            .animation(.easeInOut(duration: 0.25), value: qcGroup.isCompleted)
        }
        
        private struct SegmentPath: Shape {
            var value: Double
            let criteriaCount: Int
            let index: Int
            let lowerBoundValue: Double
            let upperBoundValue: Double
            
            var animatableData: Double {
                get { value }
                set { value = newValue }
            }
            
            func path(in rect: CGRect) -> Path {
                var path = Path()
                
                path.move(to: CGPoint(x: rect.midX, y: rect.midY))
                path.addArc(
                    center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: rect.midX * ((value - lowerBoundValue) / (upperBoundValue - lowerBoundValue)),
                    startAngle: .degrees(Double(360)/Double(criteriaCount) * Double(index)),
                    endAngle: .degrees(Double(360)/Double(criteriaCount) * Double(index + 1)),
                    clockwise: false
                )
                
                return path
            }
        }
    }
    
    private struct RoseChartGrid: Shape {
        let categoriesCount: Int
        let divisionsCount: Int
        
        func path(in rect: CGRect) -> Path {
            let radius = min(rect.maxX - rect.midX, rect.maxY - rect.midY)
            let stride = radius / CGFloat(divisionsCount)
            var path = Path()
            
            for category in 1 ... categoriesCount {
                path.move(to: CGPoint(x: rect.midX, y: rect.midY))
                path.addLine(to: CGPoint(
                    x: rect.midX + cos(CGFloat(category) * 2 * .pi / CGFloat(categoriesCount) - .pi / 2) * radius,
                    y: rect.midY + sin(CGFloat(category) * 2 * .pi / CGFloat(categoriesCount) - .pi / 2) * radius
                ))
            }
            
            for step in 1 ... divisionsCount {
                let circleRadius = CGFloat(step) * stride
                
                let circleContainer = CGRect(
                    x: rect.midX - circleRadius,
                    y: rect.midY - circleRadius,
                    width: circleRadius * 2,
                    height: circleRadius * 2
                )
                
                path.addEllipse(in: circleContainer)
            }
            
            return path
        }
    }
    
    private struct RoseChartLabels: View {
        let qualityCriteria: [QualityCriteria]
        let geometry: GeometryProxy
        
        var body: some View {
            let rect: CGRect = CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height)
            let radius: CGFloat = min(rect.maxX - rect.midX, rect.maxY - rect.midY) + 10
            
            ZStack {
                ForEach(Array(qualityCriteria.enumerated()), id: \.offset) { index, qualityCriteria in
                    let a: CGFloat = 2 * .pi / CGFloat(self.qualityCriteria.count)
                    let pointX: CGFloat = rect.midX + cos(CGFloat(index) * a - .pi / 2) * radius
                    let pointY: CGFloat = rect.midY + sin(CGFloat(index) * a - .pi / 2) * radius
                    
                    let labelKey: LocalizedStringKey = .init("\(qualityCriteria.title).short")
                    Text(labelKey)
                        .font(.caption2)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                        .position(x: pointX, y: pointY)
                }
            }
        }
    }
}
