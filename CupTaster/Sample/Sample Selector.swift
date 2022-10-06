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
            ZStack(alignment: .bottom) {
                HStack(spacing: cuppingModel.switchingSamplesAppearance ? 50 : 0) {
                    ForEach(cuppingModel.sortedSamples) { sample in
                        SampleView(cuppingModel: cuppingModel, sample: sample, appearance: $cuppingModel.samplesAppearance)
                            .frame(width: geometry.size.width)
                            .matchedGeometryEffect(id: sample.id, in: namespace)
                            .opacity(cuppingModel.switchingSamplesAppearance && cuppingModel.selectedSample != sample ? 0 : 1)
                            .scaleEffect(cuppingModel.switchingSamplesAppearance && cuppingModel.selectedSample == sample ? 0.7 + (cuppingModel.offset.height/(geometry.size.height*2)) : 1)
                    }
                }
                .offset(x: cuppingModel.offset.width - (geometry.size.width + (cuppingModel.switchingSamplesAppearance ? 50 : 0)) * CGFloat(cuppingModel.selectedSampleIndex ?? 0))
                .frame(width: geometry.size.width, alignment: .leading)
            }
        }
    }
}
