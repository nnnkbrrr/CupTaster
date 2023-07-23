//
//  Sample Controller.swift
//  CupTaster
//
//  Created by Никита Баранов on 23.07.2023.
//

import SwiftUI

struct SamplesControllerView: View {
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    
    var body: some View {
        if let sample = samplesControllerModel.selectedSample {
//        if let cupping = samplesControllerModel.cupping {
//            ForEach(cupping.getSortedSamples()) { sample in
                SampleView(sample)
                    .safeAreaInset(edge: .bottom) {
                        Button("Exit") {
                            samplesControllerModel.exit()
                        }
                    }
                    .background(Color.systemGroupedBackground)
//            }
        }
    }
}
