//
//  Sample Chart Section.swift
//  CupTaster
//
//  Created by Никита Баранов on 26.12.2023.
//

import SwiftUI

extension SampleView {
    struct ChartSection: View {
        @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
        
        var body: some View {
            if samplesControllerModel.isActive {
                VStack(spacing: .extraSmall) {
                    let matchedGeometryId: String = {
                        let activityIndicator: String = samplesControllerModel.isTogglingVisibility ? "" : ".inactive"
                        if let selectedSample: Sample = samplesControllerModel.selectedSample {
                            return "radar.chart.\(selectedSample.id)" + activityIndicator
                        }
                        return "radar.chart.empty"
                    }()
                    
                    RoseChart()
                        .matchedGeometryEffect(
                            id: matchedGeometryId,
                            in: samplesControllerModel.namespace
                        )
                        .zIndex(2.1)
                    
//                    if let sample = samplesControllerModel.selectedSample {
//                        FoldersSection(sample: sample)
//                    }
                }
                .padding(.small)
            } else {
                Color.clear
            }
        }
        
        struct FoldersSection: View {
            @ObservedObject var sample: Sample
            
            var body: some View {
                if sample.folders.isEmpty {
                    HStack {
                        Image(systemName: "folder.badge.gearshape")
                        
                        Text("Manage Folders")
                            .font(.caption)
                    }
                    .foregroundStyle(Color.accentColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: .smallElement)
                    .background(Color.backgroundTertiary)
                    .cornerRadius()
                    .onTapGesture {
#warning("manage folders")
                    }
                } else {
#warning("folders")
                }
            }
        }
    }
}
