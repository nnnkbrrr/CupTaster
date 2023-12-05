//
//  Sample Radar Stats.swift
//  CupTaster
//
//  Created by Никита Баранов on 24.07.2023.
//

import SwiftUI

extension SampleView {
    @ViewBuilder func sampleChart(sample: Sample) -> some View {
        VStack {
            RadarChart(sample: sample, style: .compact)
                .background(Color.backgroundSecondary)
                .padding(.bottom, .small)
                .frame(maxWidth: .infinity)
                .matchedGeometryEffect(id: "radar.chart.\(sample.id)", in: samplesControllerModel.namespace)
                .zIndex(1.1)
        }
        .padding(.small)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                .foregroundColor(.backgroundSecondary)
        )
        .matchedGeometryEffect(
            id: "radar.chart.container.\(sample.id)",
            in: samplesControllerModel.namespace
        )
        .scaleEffect(radarChartZoomedOnAppear ? 1.25 : 1)
        .zIndex(1.2)
    }
}
