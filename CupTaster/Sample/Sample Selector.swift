//
//  SampleEditor.swift
//  CupTaster
//
//  Created by Никита on 10.07.2022.
//

import SwiftUI

struct SampleSelectorView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var cuppingModel: CuppingModel
    var namespace: Namespace.ID
    
    init(cuppingModel: CuppingModel, namespace: Namespace.ID) {
        self.cuppingModel = cuppingModel
        self.namespace = namespace
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: cuppingModel.switchingToPreviews ? 50 : 0) {
                    let selectedSampleOrdinalNumber: Int16 = cuppingModel.selectedSample!.ordinalNumber
                    ForEach(cuppingModel.sortedSamples) { sample in
                        if selectedSampleOrdinalNumber - 1...selectedSampleOrdinalNumber + 1 ~= sample.ordinalNumber {
                            SampleView(cuppingModel: cuppingModel, sample: sample, appearance: $cuppingModel.samplesAppearance)
                                .frame(width: geometry.size.width)
                                .matchedGeometryEffect(id: sample.id, in: namespace)
                                .opacity(cuppingModel.switchingToPreviews && cuppingModel.selectedSample != sample ? 0 : 1)
                                .transition(.opacity.combined(with: .scale))
                        } else {
                            Text(sample.name)
                                .padding()
                                .padding(.horizontal)
                                .frame(width: geometry.size.width)
                                .matchedGeometryEffect(id: sample.id, in: namespace)
                        }
                    }
                }
                .offset(x: cuppingModel.offset.width - (geometry.size.width + (cuppingModel.switchingToPreviews ? 50 : 0)) * CGFloat(cuppingModel.selectedSampleIndex ?? 0))
                .frame(width: geometry.size.width, alignment: .leading)
                .scaleEffect(
                    cuppingModel.switchingToPreviews ?
                    0.7 + (cuppingModel.offset.height/(geometry.size.height * 2)) : 1
                )
            }
        }
    }
}
