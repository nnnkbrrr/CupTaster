//
//  Chart.swift
//  CupTaster
//
//  Created by Никита Баранов on 12.07.2023.
//

import SwiftUI

private struct RadarChartGrid: Shape {
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
                x: rect.midY - circleRadius,
                y: rect.midY - circleRadius,
                width: circleRadius * 2,
                height: circleRadius * 2
            )
            
            path.addEllipse(in: circleContainer)
        }
        
        return path
    }
}

private struct RadarChartPath: Shape {
    @State var qualityCriteria: [QualityCriteria]
    let minimum: CGFloat
    let maximum: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = min(rect.maxX - rect.midX, rect.maxY - rect.midY)
        var path = Path()
        
        var needToMovePoint: Bool = true
        var firstPoint: CGPoint? = nil
        
        for (index, qc) in qualityCriteria.enumerated() {
            if qc.group.isCompleted {
                let value: CGFloat = (qc.value-minimum)/(maximum-minimum)
                let angle: CGFloat = CGFloat(index) * 2 * .pi / CGFloat(qualityCriteria.count) - .pi / 2
                
                let pointX: CGFloat = rect.midX + value * cos(angle) * radius
                let pointY: CGFloat = rect.midY + value * sin(angle) * radius
                
                if needToMovePoint {
                    path.move(to: CGPoint(x: pointX, y: pointY))
                    needToMovePoint = false
                } else {
                    path.addLine(to: CGPoint(x: pointX, y: pointY))
                }
                
                if index == 0 { firstPoint = CGPoint(x: pointX, y: pointY) }
                if let firstPoint, index == qualityCriteria.count - 1 {
                    path.addLine(to: firstPoint)
                }
            } else {
                needToMovePoint = true
            }
        }
        return path
    }
}

private struct RadarChartPathMarks: Shape {
    let qualityCriteria: [QualityCriteria]
    let minimum: CGFloat
    let maximum: CGFloat

    let pointRadius: CGFloat = 2
    
    func path(in rect: CGRect) -> Path {
        let radius = min(rect.maxX - rect.midX, rect.maxY - rect.midY)
        var path = Path()

        for (index, qc) in qualityCriteria.enumerated() {
            if qc.group.isCompleted {
                let value: CGFloat = (qc.value-minimum)/(maximum-minimum)
                let angle: CGFloat = CGFloat(index) * 2 * .pi / CGFloat(qualityCriteria.count) - .pi / 2

                let pointX: CGFloat = rect.midX + value * cos(angle) * radius
                let pointY: CGFloat = rect.midY + value * sin(angle) * radius

                path.addEllipse(in: CGRect(x: pointX - pointRadius, y: pointY - pointRadius, width: pointRadius*2, height: pointRadius*2))
            }
        }
        return path
    }
}

private struct RadarChartLabels: View {
    let qualityCriteria: [QualityCriteria]
    let geometry: GeometryProxy
    let useShortLabels: Bool
    
    var body: some View {
        let rect: CGRect = CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height)
        let radius: CGFloat = min(rect.maxX - rect.midX, rect.maxY - rect.midY) + 10
        
        ZStack {
            ForEach(qualityCriteria) { qc in
                let index: Int = qualityCriteria.sorted(by: <).firstIndex(where: { $0.id == qc.id })!
                let a: CGFloat = 2 * .pi / CGFloat(qualityCriteria.count)
                let pointX: CGFloat = rect.midX + cos(CGFloat(index) * a - .pi / 2) * radius
                let pointY: CGFloat = rect.midY + sin(CGFloat(index) * a - .pi / 2) * radius
                
                Group {
                    if useShortLabels {
                        let labelKey: LocalizedStringKey = .init("\(qc.title).short")
                        Text(labelKey)
                            .font(.caption2)
                    } else {
                        let labelKey: LocalizedStringKey = .init("\(qc.title)")
                        Text(labelKey)
                            .font(.caption)
                            .lineLimit(2)
                    }
                }
                .foregroundColor(.primary)
                .position(x: pointX, y: pointY)
            }
        }
    }
}

struct RadarChart: View {
    enum Style { case `default`, compact}
    
    #warning("chart does not update on changes")
    @ObservedObject var sample: Sample
    @State private var visibleQC: [QualityCriteria]

    let style: Self.Style
    
    init(sample: Sample, style: Style = .default) {
        self.sample = sample
        self.visibleQC = sample.qualityCriteriaGroups
            .sorted(by: { $0.configuration.ordinalNumber < $1.configuration.ordinalNumber })
            .flatMap { $0.qualityCriteria }
            .filter { $0.configuration.evaluationType.unwrappedEvaluation is SliderEvaluation }
        self.style = style
    }
    
    var body: some View {
        let isCompleted = sample.isCompleted
        
        if let firstVisibleQC = visibleQC.first {
            GeometryReader { geometry in
                ZStack {
                    let qcConfigMin = firstVisibleQC.configuration.lowerBound
                    let qcConfigMax = firstVisibleQC.configuration.upperBound
                    
                    RadarChartGrid(categoriesCount: visibleQC.count, divisionsCount: Int(qcConfigMax - qcConfigMin))
                        .stroke(.gray, lineWidth: 0.5)
                    
                    RadarChartPath(qualityCriteria: visibleQC, minimum: qcConfigMin, maximum: qcConfigMax)
                        .stroke(Color.accentColor, lineWidth: 1)
                    
                    if isCompleted {
                        RadarChartPath(qualityCriteria: visibleQC, minimum: qcConfigMin, maximum: qcConfigMax)
                            .fill(Color.accentColor.opacity(0.5))
                    }
                    
                    if style == .default || !isCompleted {
                        RadarChartPathMarks(qualityCriteria: visibleQC, minimum: qcConfigMin, maximum: qcConfigMax)
                            .fill(Color.accentColor)
                    }
                    
                    RadarChartLabels(qualityCriteria: visibleQC, geometry: geometry, useShortLabels: style == .compact)
                }
            }
            .padding(15)
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
        } else { EmptyView() }
    }
}

private class VisibleQualityCriteria: ObservableObject {
    @Published var qualityCriteria: [QualityCriteria] = []
}
