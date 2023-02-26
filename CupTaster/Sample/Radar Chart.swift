//
//  Radar Chart View.swift
//  CupTaster
//
//  Created by Никита on 23.09.2022.
//

import SwiftUI

struct RadarChartGrid: Shape {
    let categoriesCount: Int
    let divisionsCount: Int
    
    func path(in rect: CGRect) -> Path {
        let radius = min(rect.maxX - rect.midX, rect.maxY - rect.midY) - 35
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
            let rad = CGFloat(step) * stride
            path.move(to: CGPoint(
                x: rect.midX + cos(-.pi / 2) * rad,
                y: rect.midY + sin(-.pi / 2) * rad
            ))
            
            for category in 1 ... categoriesCount {
                path.addLine(to: CGPoint(
                    x: rect.midX + cos(CGFloat(category) * 2 * .pi / CGFloat(categoriesCount) - .pi / 2) * rad,
                    y: rect.midY + sin(CGFloat(category) * 2 * .pi / CGFloat(categoriesCount) - .pi / 2) * rad
                ))
            }
        }
        
        return path
    }
}

struct RadarChartPath: Shape {
    let qualityCriteria: [QualityCriteria]
    let minimum: CGFloat
    let maximum: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = min(rect.maxX - rect.midX, rect.maxY - rect.midY) - 35
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

struct RadarChartPathMarks: Shape {
    let qualityCriteria: [QualityCriteria]
    let minimum: CGFloat
    let maximum: CGFloat

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.maxX - rect.midX, rect.maxY - rect.midY) - 35
        var path = Path()

        for (index, qc) in qualityCriteria.enumerated() {
            if qc.group.isCompleted {
                let value: CGFloat = (qc.value-minimum)/(maximum-minimum)
                let angle: CGFloat = CGFloat(index) * 2 * .pi / CGFloat(qualityCriteria.count) - .pi / 2

                let pointX: CGFloat = rect.midX + value * cos(angle) * radius
                let pointY: CGFloat = rect.midY + value * sin(angle) * radius

                path.addEllipse(in: CGRect(x: pointX - 3, y: pointY - 3, width: 6, height: 6))
            }
        }
        return path
    }
}

struct RadarChartLabels: View {
    let qualityCriteria: [QualityCriteria]
    let geometry: GeometryProxy
    let useShortLabels: Bool
    
    var body: some View {
        let rect: CGRect = CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height)
        let radius: CGFloat = min(rect.maxX - rect.midX, rect.maxY - rect.midY) - 25
        
        ZStack {
            ForEach(qualityCriteria) { qc in
                let index: Int = qualityCriteria.sorted(by: <).firstIndex(where: { $0.id == qc.id })!
                let a: CGFloat = 2 * .pi / CGFloat(qualityCriteria.count)
                let pointX: CGFloat = rect.midX + cos(CGFloat(index) * a - .pi / 2) * radius
                let pointY: CGFloat = rect.midY + sin(CGFloat(index) * a - .pi / 2) * radius
                
                Group {
                    if useShortLabels {
                        Text(shortLabel(qc.title))
                            .font(.caption2)
                            .bold()
                    } else {
                        Text(qc.title)
                            .font(.caption)
                    }
                }
                .frame(maxWidth: 70)
                .foregroundColor(.primary)
                .position(x: pointX, y: pointY)
            }
        }
    }
    
    func shortLabel(_ fullTitle: String) -> String {
        return String([fullTitle.first!, fullTitle.first(where: { !$0.isVowel && $0.isLowercase })!])
    }
}

#warning("use explicit shorten label on every criteria")
extension Character {
    var isVowel: Bool {
        switch self {
            case "a", "i", "u", "e", "o" : return true
            default: return false
        }
    }
}

struct RadarChart: View {
    @ObservedObject var sample: Sample
    let useShortLabels: Bool
    
    init(sample: Sample, useShortLabels: Bool = false) {
        self.sample = sample
        self.useShortLabels = useShortLabels
    }
    
    var body: some View {
        let visibleQC: [QualityCriteria] =
        sample.qualityCriteriaGroups
            .sorted(by: { $0.configuration.ordinalNumber < $1.configuration.ordinalNumber })
            .flatMap { $0.qualityCriteria }
            .filter { $0.configuration!.evaluationType.unwrappedEvaluationType == .slider }
        
        if let firstVisibleQC = visibleQC.first {
            GeometryReader { geometry in
                ZStack {
                    let qcConfigMin = firstVisibleQC.configuration!.lowerBound
                    let qcConfigMax = firstVisibleQC.configuration!.upperBound

                    RadarChartGrid(categoriesCount: visibleQC.count, divisionsCount: Int(qcConfigMax - qcConfigMin))
                        .stroke(.gray, lineWidth: 0.5)

                    RadarChartPath(qualityCriteria: visibleQC, minimum: qcConfigMin, maximum: qcConfigMax)
                        .stroke(Color.accentColor, lineWidth: 1)

                    RadarChartPathMarks(qualityCriteria: visibleQC, minimum: qcConfigMin, maximum: qcConfigMax)
                        .fill(Color.accentColor)
                    
                    RadarChartLabels(qualityCriteria: visibleQC, geometry: geometry, useShortLabels: useShortLabels)
                }
            }
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
        } else { EmptyView() }
    }
}


