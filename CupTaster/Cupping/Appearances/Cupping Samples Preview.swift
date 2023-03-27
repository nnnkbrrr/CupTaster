//
//  Cupping Samples Preview.swift
//  CupTaster
//
//  Created by Никита Баранов on 20.03.2023.
//

import SwiftUI

extension CuppingView {
	var samplesPreview: some View {
		ScrollView {
			LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 200))]) {
				ForEach(samples) { sample in
					Button {
						cuppingModel.selectedSample = sample
						cuppingModel.selectedSampleIndex = cuppingModel.sortedSamples.firstIndex(of: sample)!
						cuppingModel.samplesAppearance = .criteria
						cuppingModel.offset = .zero
						cuppingModel.switchingToPreviews = false
						
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
							withAnimation {
								cuppingModel.sampleViewVisible = true
							}
						}
					} label: {
						SampleView(cuppingModel: cuppingModel, sample: sample).preview
					}
					.matchedGeometryEffect(id: sample.id, in: namespace)
					.zIndex(cuppingModel.selectedSample?.id == sample.id ? 1 : 0)
				}
			}
			.padding(20)
		}
	}
}
