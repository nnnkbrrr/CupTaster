//
//  Cupping Selected Hint.swift
//  CupTaster
//
//  Created by Никита Баранов on 20.03.2023.
//

import SwiftUI

extension CuppingView {
	var selectedHint: some View {
		ZStack {
			if let qcGroupConfig = cuppingModel.selectedHintsQCGConfig {
				ScrollView(showsIndicators: false) {
					HintsMenuView(qcGroupConfig: qcGroupConfig)
						.padding(50)
				}
				.background(.ultraThinMaterial)
				.safeAreaInset(edge: .bottom) {
					Button {
						withAnimation {
							cuppingModel.selectedHintsQCGConfig = nil
						}
					} label: {
						Text("Done")
							.foregroundColor(.white)
							.padding()
							.frame(maxWidth: .infinity)
							.background(Color.accentColor)
							.cornerRadius(15)
							.shadow(radius: 15)
							.padding([.horizontal, .bottom], 50)
					}
				}
			}
		}
		.transition(.move(edge: .bottom))
		.zIndex(3)
	}
}
