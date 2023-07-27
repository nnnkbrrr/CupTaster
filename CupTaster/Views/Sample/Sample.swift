//
//  Sample.swift
//  CupTaster
//
//  Created by Никита Баранов on 12.07.2023.
//

import SwiftUI

struct SampleView: View {
    @Environment(\.managedObjectContext) private var moc
    @State var sample: Sample
    
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    @State var radarChartZoomed: Bool = false
    
    init(_ sample: Sample) {
        self.sample = sample
    }
    
    var body: some View {
#warning("view: sample")
        ScrollView {
            VStack(spacing: .regular) {
                HStack(spacing: .regular) {
                    sampleChart
                    sampleTools
                }
                .zIndex(1.1)
                
                ForEach(sample.sortedQCGroups) { qcGroup in
                    ForEach(qcGroup.sortedQualityCriteria) { criteria in
                        if let criteriaConfig: QCConfig = criteria.configuration {
                            Text(criteriaConfig.title)
                        }
                    }
                }
            }
            .padding(.regular)
        }
        .onAppear {
            withAnimation(.bouncy(duration: 0.2)) {
                radarChartZoomed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.bouncy(duration: 0.2, extraBounce: 0.2)) {
                    radarChartZoomed = false
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                let generator = UIImpactFeedbackGenerator(style: .soft)
                generator.impactOccurred()
            }
        }
    }
}
