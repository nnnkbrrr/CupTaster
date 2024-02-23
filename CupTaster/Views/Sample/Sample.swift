//
//  Sample.swift
//  CupTaster
//
//  Created by Никита Баранов on 12.07.2023.
//

import SwiftUI

struct SampleView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    @State var radarChartZoomedOnAppear: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                let spacing: CGFloat = .extraSmall
                let gridCellSize: CGFloat = (geometry.size.width - spacing * 6) / 5
                
                VStack(spacing: spacing) {
                    let gridSize2: CGFloat = getElementSize(2, gridCellSize: gridCellSize, spacing: spacing)
                    let gridSize3: CGFloat = getElementSize(3, gridCellSize: gridCellSize, spacing: spacing)
                    
                    HStack(spacing: spacing) {
                        VStack(spacing: spacing) {
                            ActionsToolsSection()
                                .sampleBlock(width: gridSize3, height: .smallElementContainer)
                            
                            let matchedGeometryId: String = {
                                let activityIndicator: String = samplesControllerModel.isTogglingVisibility ? "" : ".inactive"
                                var animationId: String {
                                    if let sampleAnimationID = samplesControllerModel.sampleAnimationID { return sampleAnimationID.uuidString }
                                    else { return "no-animation-id" }
                                }
                                if let selectedSample: Sample = samplesControllerModel.selectedSample {
                                    return "\(animationId).radar.chart.\(selectedSample.id).container" + activityIndicator
                                }
                                return "\(animationId).radar.chart.empty.container"
                            }()
                            
                            if samplesControllerModel.isActive {
                                ChartSection()
                                    .padding(.vertical, .large)
                                    .sampleBlock(width: gridSize3)
                                    .shadow(color: .backgroundPrimary.opacity(0.5), radius: 5, x: 0, y: 0)
                                    .scaleEffect(radarChartZoomedOnAppear ? 1.2 : 1)
                                    .matchedGeometryEffect(
                                        id: matchedGeometryId,
                                        in: NamespaceControllerModel.shared.namespace
                                    )
                            } else {
                                Color.clear
                            }
                        }
                        .zIndex(2.2)
                        
                        VStack(spacing: spacing) {
                            FinalScoreSection()
                                .sampleBlock(width: gridSize2)
                            
                            CheckboxesSummarySection()
                                .sampleBlock(width: gridSize2)
                        }
                    }
                    .zIndex(2.1)
                    
                    GeneralInfoToolsSection()
                        .sampleBlock(height: .smallElementContainer)
                    
                    GeneralInfoSection(gridCellSize: gridCellSize)
                }
                .padding(.vertical, .small)
                .padding(.horizontal, .extraSmall)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Spacer().frame(height: SampleBottomSheetConfiguration.minHeight)
        }
        .onAppear { chartAppearAnimation() }
    }
    
    func getElementSize(_ multiplier: Int, gridCellSize: CGFloat, spacing: CGFloat) -> CGFloat {
        return gridCellSize * CGFloat(multiplier) + spacing * CGFloat(multiplier - 1)
    }
    
    func chartAppearAnimation() {
        withAnimation(.bouncy(duration: 0.2)) {
            radarChartZoomedOnAppear = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.bouncy(duration: 0.2, extraBounce: 0.2)) {
                radarChartZoomedOnAppear = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
        }
    }
}
