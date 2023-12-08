//
//  Sample Final Score Section.swift
//  CupTaster
//
//  Created by Никита Баранов on 08.12.2023.
//

import SwiftUI

extension SampleView {
    struct FinalScoreSection: View {
        @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
        let finalScoreLowerBound: Double
        let finalScoreUpperBound: Double
        
        init() {
            let cupping = SamplesControllerModel.shared.cupping
            finalScoreLowerBound = cupping?.form?.finalScoreLowerBound ?? 0
            finalScoreUpperBound = cupping?.form?.finalScoreUpperBound ?? 0
        }
        
        @State var finalScore: Double? = nil
        
        var body: some View {
            VStack(spacing: .regular) {
                GeometryReader { geometry in
                    ZStack {
                        let radius: CGFloat = geometry.size.width / 2
                        let count: CGFloat = 40
                        let relativeDashLength: CGFloat = 0.1
                        let dashLength = CGFloat(2 * .pi * radius) / count
                        let paintedSegmentsLength: CGFloat = dashLength * relativeDashLength
                        let unpaintedSegmentsLength: CGFloat = dashLength * (1 - relativeDashLength)
                        
                        CircularProgressView(
                            progress: ((finalScore ?? finalScoreLowerBound) - finalScoreLowerBound) / (finalScoreUpperBound - finalScoreLowerBound),
                            style: StrokeStyle(
                                lineWidth: 5,
                                lineCap: .round,
                                dash: [paintedSegmentsLength, unpaintedSegmentsLength]
                            ),
                            progressColor: .accentColor
                        )
                        .animation(.smooth, value: finalScore)
                        
                        if let sample: Sample = samplesControllerModel.selectedSample {
                            ForEach(sample.qualityCriteriaGroups.flatMap { $0.sortedQualityCriteria }) { criteria in
                                ScoreUpdater(criteria: criteria, finalScore: $finalScore)
                            }
                        }
                        
                        if let finalScore {
                            Text(String(format: "%.1f", finalScore))
                                .font(.title)
                                .fontWeight(.light)
                                .padding(.small)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                
                Text("Final\nScore")
                    .font(.caption)
                    .textCase(.uppercase)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
            }
            .padding([.horizontal, .top], .regular)
            .padding(.bottom, .small)
            .onAppear {
                finalScore = samplesControllerModel.selectedSample?.finalScore
            }
            .onChange(of: samplesControllerModel.selectedSample) { sample in
                finalScore = sample?.finalScore
            }
        }
        
        struct ScoreUpdater: View {
            @ObservedObject var criteria: QualityCriteria
            @Binding var finalScore: Double?
            
            var body: some View {
                EmptyView()
                    .onChange(of: criteria.value) { _ in
                        finalScore = criteria.group.sample.finalScore
                    }
            }
        }
    }
}
