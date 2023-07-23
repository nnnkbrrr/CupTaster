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
                .matchedGeometryEffect(id: "radar.chart.\(sample.id)", in: samplesControllerModel.namespace)
                .frame(maxWidth: .infinity)
            
            Text(sample.name)
                .font(.subheadline)
            
            HStack {
                Text("Final score: ")
                    .foregroundStyle(.gray)
#warning("final score value")
                Spacer()
                
                if sample.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                }
            }
            .font(.caption)
        }
        .padding(.small)
        .background(
            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                .foregroundColor(.secondarySystemGroupedBackground)
        )
        .matchedGeometryEffect(
            id: "radar.chart.container.\(sample.id)",
            in: samplesControllerModel.namespace
        )
        .contextMenu {
#warning("context menu")
            Button("Open") {
                samplesControllerModel.setActiveCupping(cupping: cupping, sample: sample)
            }
        }
        .onTapGesture {
            samplesControllerModel.setActiveCupping(cupping: cupping, sample: sample)
        }
    }
}
