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
        ScrollView(showsIndicators: false) {
            VStack(spacing: .regular) {
                HStack(spacing: .regular) {
                    // sampleChart(sample: sample)
                    sampleTools
                }
                .frame(height: 220)
                
                // Text(String(format: "%.1f", sample.finalScore))
                //     .padding(.small)
                //     .frame(maxWidth: .infinity)
                //     .background(
                //         RoundedRectangle(cornerRadius: .defaultCornerRadius)
                //             .foregroundColor(.secondarySystemGroupedBackground)
                //     )
                
                Text(String(format: "%.1f", samplesControllerModel.selectedSample?.finalScore ?? -1))
                    .padding(.small)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: .defaultCornerRadius)
                            .foregroundColor(.secondarySystemGroupedBackground)
                    )
                
                RoundedRectangle(cornerRadius: .defaultCornerRadius)
                    .frame(height: 500)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.secondarySystemGroupedBackground)
            }
            .padding(.extraSmall)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .safeAreaInset(edge: .bottom) {
            Spacer().frame(height: BottomSheetConfiguration.minHeight)
        }
        .onAppear { chartAppearAnimation() }
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
