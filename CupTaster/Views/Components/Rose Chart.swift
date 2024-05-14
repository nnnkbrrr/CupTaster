//
//  Rose Chart.swift
//  CupTaster
//
//  Created by Никита Баранов on 26.12.2023.
//

import SwiftUI

struct RoseChart: View {
    let qualityCriteria: [QualityCriteria]?
    @Binding var selectedSample: Sample?
    let cuppingForm: CuppingForm?
    
    init(sample: Sample) {
        self.qualityCriteria = sample.qualityCriteriaGroups
            .sorted(by: { $0.configuration.ordinalNumber < $1.configuration.ordinalNumber })
            .flatMap { $0.qualityCriteria }
            .filter { $0.configuration.evaluationType.unwrappedEvaluation is SliderEvaluation }
        
        self._selectedSample = .constant(nil)
        self.cuppingForm = sample.cupping.form
    }
    
    init() {
        self.qualityCriteria = nil
        self.cuppingForm = SamplesControllerModel.shared.cupping?.form
        self._selectedSample = Binding<Sample?>(
            get: { SamplesControllerModel.shared.selectedSample },
            set: { _ in }
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let qualityCriteria: [QualityCriteria]? = {
                    if let qualityCriteria = self.qualityCriteria {
                        return qualityCriteria
                    } else if let selectedSample {
                        return selectedSample.qualityCriteriaGroups
                            .sorted(by: { $0.configuration.ordinalNumber < $1.configuration.ordinalNumber })
                            .flatMap { $0.qualityCriteria }
                            .filter { $0.configuration.evaluationType.unwrappedEvaluation is SliderEvaluation }
                    }
                    return nil
                }()

                let chartQualityCriteria: [QualityCriteria]? = {
                    guard let cuppingForm else { return nil }
                    let qualityCriteria: [QualityCriteria] = cuppingForm.qcGroupConfigurations
                        .sorted(by: { $0.ordinalNumber < $1.ordinalNumber })
                        .flatMap { $0.qcConfigurations }
                        .filter { $0.evaluationType.unwrappedEvaluation is SliderEvaluation }
                    
                    return qualityCriteria == [] ? nil : qualityCriteria
                }()
                
                if let qualityCriteria {
                    ZStack {
                        ForEach(Array(qualityCriteria.enumerated()), id: \.offset) { index, qualityCriterion in
                            if qualityCriterion.isFault {
                                EmptyView()
                            } else {
                                RoseChartSegment(qualityCriteria: qualityCriterion, in: qualityCriteria)
                                    .animation(.easeInOut(duration: 1), value: qualityCriterion.value)
                            }
                        }
                    }
                    .rotationEffect(.degrees(-90))
                    .transition(.scale)
                }
                
                if let qualityCriteria: [QualityCriteria] = chartQualityCriteria ?? qualityCriteria {
                    RoseChartGrid(categoriesCount: qualityCriteria.count, divisionsCount: 4)
                        .stroke(.gray.opacity(0.5), lineWidth: 0.5)
                    
                    RoseChartLabels(qualityCriteriaLabels: qualityCriteria.map { $0.title }, geometry: geometry)
                }
            }
            .animation(.bouncy(duration: 0.5).delay(0.2), value: selectedSample)
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
            .foregroundColor(Color.accentColor.opacity(0.5))
            .disabled(!qcGroup.isCompleted)
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
            
            guard categoriesCount > 1 else { return path }
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
        let qualityCriteriaLabels: [String]
        let geometry: GeometryProxy
        
        var body: some View {
            let rect: CGRect = CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height)
            let radius: CGFloat = min(rect.maxX - rect.midX, rect.maxY - rect.midY) + 10
            
            ZStack {
                ForEach(Array(qualityCriteriaLabels.enumerated()), id: \.offset) { index, label in
                    let a: CGFloat = 2 * .pi / CGFloat(qualityCriteriaLabels.count)
                    let pointX: CGFloat = rect.midX + cos((CGFloat(index) + 0.5) * a - .pi / 2) * radius
                    let pointY: CGFloat = rect.midY + sin((CGFloat(index) + 0.5) * a - .pi / 2) * radius
                    
                    let labelWords: [String] = label.components(separatedBy: .whitespacesAndNewlines)
                    
                    let shortLabel: String = {
                        if labelWords.count > 1 {
                            return String(labelWords[0].prefix(1)) + String(labelWords[1].prefix(1))
                        } else if label.count < 4 {
                            return label
                        } else {
                            return String(label.prefix(2))
                        }
                    }()
                    
                    Text(shortLabel)
                        .font(.caption2)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                        .position(x: pointX, y: pointY)
                }
            }
        }
    }
}
