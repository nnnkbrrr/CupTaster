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
    let showCupping: Bool
    let animationId: UUID?
    
    init(_ sample: Sample, showCupping: Bool = false, animationId: UUID? = nil) {
        self.sample = sample
        self.showCupping = showCupping
        self.animationId = animationId
    }
    
    var body: some View {
        var matchedGeometryId: String {
            var matchedGeometryAnimationDescription: String {
                if let animationId { return animationId.uuidString }
                else { return "no-animation-id" }
            }
            return "\(matchedGeometryAnimationDescription).radar.chart.\(sample.id)"
        }
        
        if samplesControllerModel.selectedSample != sample {
            VStack(alignment: .leading) {
                RoseChart(sample: sample)
                    .frame(maxWidth: .infinity)
                    .matchedGeometryEffect(
                        id: matchedGeometryId,
                        in: NamespaceControllerModel.shared.namespace
                    )
                    .zIndex(2.1)
                    .aspectRatio(contentMode: .fit)
                
                Text(sample.name)
                    .font(.subheadline)
                
                if showCupping { CuppingLink(cupping: sample.cupping) }
                
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
                id: matchedGeometryId + ".container",
                in: NamespaceControllerModel.shared.namespace
            )
            .zIndex(2.1)
            .contextMenu {
#warning("context menu")
                Button("Open") {
                    samplesControllerModel.setSelectedSample(sample, animationId: animationId)
                }
            }
            .onTapGesture {
                samplesControllerModel.setSelectedSample(sample, animationId: animationId)
            }
        } else {
            Color.clear
                .frame(minHeight: 200)
        }
    }
    
    struct CuppingLink: View {
        @ObservedObject var cupping: Cupping
        
        var body: some View {
            NavigationLink(destination: CuppingView(cupping)) {
                Group {
                    Text(Image(systemName: "arrow.turn.down.right")) +
                    Text(" ") +
                    Text(cupping.name)
                }
                .font(.caption)
                .multilineTextAlignment(.leading)
            }
        }
    }
}

