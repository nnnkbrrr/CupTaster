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
            if let sample: Sample = samplesControllerModel.selectedSample {
                VStack(spacing: .extraSmall) {
                    RoseChart(sample: sample)
                        .matchedGeometryEffect(
                            id: "radar.chart.\(sample.id)",
                            in: samplesControllerModel.namespace
                        )
                        .zIndex(2.1)
                    
                    FoldersSection(sample: sample)
                }
                .padding(.small)
            }
//            elseif let form: CuppingForm = samplesControllerModel.cupping?.form {
//                VStack(spacing: .extraSmall) {
//                    RoseChart(placeholderFrom: form)
//                    
//                    Spacer()
//                        .frame(height: .smallElement)
//                }
//                .padding(.small)
//            }
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
