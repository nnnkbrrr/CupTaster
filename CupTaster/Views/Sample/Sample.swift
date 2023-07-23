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
            VStack {
                Text(sample.name)
                
                HStack(spacing: .regular) {
                    VStack(alignment: .leading) {
#warning("actual score")
                        Text("69.0")
                            .font(.largeTitle)
                            .fontWeight(.light)
                        
                        Text("Final Score")
                            .foregroundStyle(.gray)
                        
                        RadarChart(sample: sample, style: .compact)
                            .matchedGeometryEffect(id: "radar.chart.\(sample.id)", in: samplesControllerModel.namespace)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, .small)
                    }
                    .padding(.small)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: .defaultCornerRadius)
                            .foregroundColor(.secondarySystemGroupedBackground)
                    )
                    .matchedGeometryEffect(
                        id: "radar.chart.container.\(sample.id)",
                        in: samplesControllerModel.namespace
                    )
                    .scaleEffect(radarChartZoomed ? 1.25 : 1)
                    .zIndex(2)
                    
                    sampleTools
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.secondarySystemGroupedBackground)
                        .cornerRadius()
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
