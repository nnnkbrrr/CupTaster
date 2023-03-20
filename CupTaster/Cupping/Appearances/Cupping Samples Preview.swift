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
			Text(cuppingModel.cupping.name)
				.font(.largeTitle)
				.fontWeight(.heavy)
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding([.top, .horizontal], 20)
			
			LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
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
			.padding([.bottom, .horizontal])
			.padding(.bottom, 44) // toolbar
		}
		.clipped()
	}
}
