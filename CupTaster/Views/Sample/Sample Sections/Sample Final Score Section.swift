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
        @State var finalScore: Double? = nil
        let finalScoreLowerBound: Double
        let finalScoreUpperBound: Double
        
        init() {
            let cupping = SamplesControllerModel.shared.cupping
            finalScoreLowerBound = cupping?.form?.finalScoreLowerBound ?? 0
            finalScoreUpperBound = cupping?.form?.finalScoreUpperBound ?? 0
        }
        
        var body: some View {
            VStack(spacing: .regular) {
                GeometryReader { geometry in
                    ZStack {
                        let lineWidth: CGFloat = 5
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
                            
                            HStack(spacing: 0) {
                                let finalScoreString: String = String(format: "%.2f", finalScore).filter { $0.isNumber }
                                let finalScoreLen: Int = finalScoreString.count
                                
                                ForEach(0..<finalScoreLen, id: \.self) { index in
                                    Text(String(finalScoreString[index]))
                                        .font(.title)
                                        .fontWeight(.light)
                                        .id(finalScoreString[...index])
                                        .transition(
                                            .asymmetric(
                                                insertion: .move(edge: index.isMultiple(of: 2) ? .bottom : .top),
                                                removal: .move(edge: index.isMultiple(of: 2) ? .top : .bottom)
                                            )
                                            .combined(with: .scale)
                                            .combined(with: .opacity)
                                        )
                                    
                                    if index == finalScoreLen - 3 {
                                        Text(".")
                                            .font(.title)
                                            .fontWeight(.light)
                                    }
                                }
                            }
                        }
                    }
                    .animation(.bouncy, value: finalScore)
                    .animation(.bouncy, value: SamplesControllerModel.shared.cupping)
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