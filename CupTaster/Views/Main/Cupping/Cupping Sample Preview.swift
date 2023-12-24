//
//  Cupping Sample Preview.swift
//  CupTaster
//
//  Created by Никита Баранов on 23.07.2023.
//

import SwiftUI

#warning("complete the view")

extension CuppingView {
    @ViewBuilder
    func samplePreview(_ sample: Sample) -> some View {
        VStack(alignment: .leading) {
            RadarChart(sample: sample, style: .compact)
                .frame(maxWidth: .infinity)
                .background(Color.backgroundSecondary)
                .matchedGeometryEffect(id: "radar.chart.\(sample.id)", in: samplesControllerModel.namespace)
                .zIndex(1.1)
            
            Text(sample.name)
                .font(.subheadline)
            
            HStack(spacing: 0) {
                Text("Final score: ")
                Text(String(format: "%.1f", sample.finalScore))
                
#warning("final score value")
                Spacer()
                
                if sample.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                }
            }
            .foregroundStyle(.gray)
            .font(.caption)
        }
        .padding(.small)
        .background(
            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                .foregroundStyle(Color.backgroundSecondary)
        )
        .matchedGeometryEffect(
            id: "radar.chart.container.\(sample.id)",
            in: samplesControllerModel.namespace
        )
        .contextMenu {
#warning("context menu")
            Button("Open") {
                samplesControllerModel.setSelectedSample(cupping: cupping, sample: sample)
            }
        }
        .onTapGesture {
            samplesControllerModel.setSelectedSample(cupping: cupping, sample: sample)
        }
    }
}
