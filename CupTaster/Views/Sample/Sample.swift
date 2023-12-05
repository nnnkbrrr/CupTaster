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
                    HStack(spacing: spacing) {
                        VStack(spacing: spacing) {
                            Rectangle()
                                .frame(width: getElementSize(3, gridCellSize: gridCellSize, spacing: spacing))
                                .frame(height: gridCellSize)
                                .cornerRadius()
                            
                            Rectangle()
                                .frame(width: getElementSize(3, gridCellSize: gridCellSize, spacing: spacing))
                                .frame(height: 300)
                                .cornerRadius()
                        }
                        
                        VStack(spacing: spacing) {
                            Rectangle()
                                .frame(width: getElementSize(2, gridCellSize: gridCellSize, spacing: spacing))
                                .frame(maxHeight: .infinity)
                                .cornerRadius()
                            
                            Rectangle()
                                .frame(width: getElementSize(2, gridCellSize: gridCellSize, spacing: spacing))
                                .frame(maxHeight: .infinity)
                                .cornerRadius()
                        }
                    }
                    
                    Rectangle()
                        .frame(width: getElementSize(5, gridCellSize: gridCellSize, spacing: spacing))
                        .frame(height: gridCellSize)
                        .cornerRadius()
                }
                .foregroundColor(.backgroundSecondary)
                .padding(.vertical, .small)
                
                // old
                
                VStack(spacing: .regular) {
                    HStack(spacing: .regular) {
                        // sampleChart(sample: sample)
                        sampleTools
                    }
                    .frame(height: 220)
                    
                    Text(String(format: "%.1f", samplesControllerModel.selectedSample?.finalScore ?? -1))
                        .padding(.small)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                                .foregroundStyle(Color.backgroundSecondary)
                        )
                    
                    RoundedRectangle(cornerRadius: .defaultCornerRadius)
                        .frame(height: 500)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color.backgroundSecondary)
                }
                .padding(.extraSmall)
                .frame(maxHeight: .infinity, alignment: .top)
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
