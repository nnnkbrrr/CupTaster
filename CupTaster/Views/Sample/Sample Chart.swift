//
//  Sample Radar Stats.swift
//  CupTaster
//
//  Created by Никита Баранов on 24.07.2023.
//

import SwiftUI

extension SampleView {
    var sampleChart: some View {
        VStack(alignment: .leading) {
            Text(String(format: "%.1f", sample.finalScore))
                .font(.largeTitle)
                .fontWeight(.light)
            
            Text("Final Score")
                .foregroundStyle(.gray)
            
            RadarChart(sample: sample, style: .compact)
                .background(Color.secondarySystemGroupedBackground)
                .padding(.vertical, .small)
                .frame(maxWidth: .infinity)
                .matchedGeometryEffect(id: "radar.chart.\(sample.id)", in: samplesControllerModel.namespace)
                .zIndex(1.1)
        }
        .padding(.small)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                .foregroundColor(.secondarySystemGroupedBackground)
        )
        .matchedGeometryEffect(
            id: "radar.chart.container.\(sample.id)",
            in: samplesControllerModel.namespace
        )
        .scaleEffect(radarChartZoomed ? 1.25 : 1)
        .zIndex(1.2)
    }
}
