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
                            in: NamespaceControllerModel.shared.namespace
                        )
                        .zIndex(2.1)
                }
                .padding(.extraSmall)
            } else {
                Color.clear
            }
        }
    }
}
