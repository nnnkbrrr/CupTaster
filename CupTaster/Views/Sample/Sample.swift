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
                                .frame(width: gridSize3)
                                .frame(height: gridCellSize)
                                .background(Color.backgroundSecondary)
                                .cornerRadius()
                            
                            let matchedGeometryId: String = {
                                let activityIndicator: String = samplesControllerModel.isTogglingVisibility ? "" : ".inactive"
                                if let selectedSample: Sample = samplesControllerModel.selectedSample {
                                    return "radar.chart.container.\(selectedSample.id)" + activityIndicator
                                }
                                return "radar.chart.container.empty"
                            }()
                            
                            if samplesControllerModel.isActive {
                                ChartSection()
                                    .frame(width: gridSize3)
                                    .background(Color.backgroundSecondary)
                                    .cornerRadius()
                                    .shadow(color: .background.opacity(0.5), radius: 5, x: 0, y: 0)
                                    .scaleEffect(radarChartZoomedOnAppear ? 1.2 : 1)
                                    .matchedGeometryEffect(
                                        id: matchedGeometryId,
                                        in: samplesControllerModel.namespace
                                    )
                            } else {
                                Color.clear
                            }
                        }
                        .zIndex(2.2)
                        
                        VStack(spacing: spacing) {
                            FinalScoreSection()
                                .frame(width: gridSize2)
                                .frame(maxHeight: .infinity)
                                .background(Color.backgroundSecondary)
                                .cornerRadius()
                            
                            CheckboxesSummarySection()
                                .frame(width: gridSize2)
                                .frame(maxHeight: .infinity)
                                .background(Color.backgroundSecondary)
                                .cornerRadius()
                        }
                    }
                    .zIndex(2.1)
                    
                    GeneralInfoToolsSection()
                        .frame(maxWidth: .infinity)
                        .frame(height: gridCellSize)
                        .background(Color.backgroundSecondary)
                        .cornerRadius()
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
