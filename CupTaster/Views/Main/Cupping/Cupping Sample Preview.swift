//
//  Cupping Sample Preview.swift
//  CupTaster
//
//  Created by Никита Баранов on 23.07.2023.
//

import SwiftUI

struct SamplePreview: View {
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    let sample: Sample
    let page: SamplesControllerModel.Page
    
    init(_ sample: Sample, page: SamplesControllerModel.Page) {
        self.sample = sample
        self.page = page
    }
    
    #warning("matched geometry")
    
    var body: some View {
        VStack(alignment: .leading) {
            RoseChart(sample: sample)
                .frame(maxWidth: .infinity)
                .matchedGeometryEffect(
                    id: "\(Optional(page)).radar.chart.\(sample.id)",
                    in: samplesControllerModel.namespace
                )
                .zIndex(2.1)
                .aspectRatio(contentMode: .fit)
            
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
        .frame(maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                .foregroundStyle(Color.backgroundSecondary)
        )
        .matchedGeometryEffect(
            id: "\(Optional(page)).radar.chart.container.\(sample.id)",
            in: samplesControllerModel.namespace
        )
        .zIndex(2.1)
        .contextMenu {
#warning("context menu")
            Button("Open") {
                samplesControllerModel.setSelectedSample(sample, page: page)
            }
        }
        .onTapGesture {
            samplesControllerModel.setSelectedSample(sample, page: page)
        }
    }
}

