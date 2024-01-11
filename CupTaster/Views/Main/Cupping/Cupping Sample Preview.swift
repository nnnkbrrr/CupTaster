//
//  Cupping Sample Preview.swift
//  CupTaster
//
//  Created by Никита Баранов on 23.07.2023.
//

import SwiftUI

#warning("complete the view")

extension CuppingView {
    struct SamplePreview: View {
        @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
        let sample: Sample
        
        init(_ sample: Sample) {
            self.sample = sample
        }
        
        var body: some View {
            VStack(alignment: .leading) {
                RoseChart(sample: sample)
                    .frame(maxWidth: .infinity)
                    .background(Color.backgroundSecondary)
                    .matchedGeometryEffect(
                        id: "radar.chart.\(sample.id)",
                        in: samplesControllerModel.namespace
                    )
                    .zIndex(2.1)
                
                Text(sample.name)
                    .font(.subheadline)
                
                HStack(spacing: 0) {
                    Text("Final score: ")
                    Text(String(format: "%.1f", sample.finalScore))
                    
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
            .zIndex(2.1)
            .contextMenu {
    #warning("context menu")
                Button("Open") {
                    samplesControllerModel.setSelectedSample(sample: sample)
                }
            }
            .onTapGesture {
                samplesControllerModel.setSelectedSample(sample: sample)
            }
        }
    }
}
