//
//  Cupping Model.swift
//  CupTaster
//
//  Created by Никита on 24.09.2022.
//

import SwiftUI

class CuppingModel: ObservableObject {
    @Published var cupping: Cupping
    
    // Cupping Settings
    
    @Published var settingsSheetIsPresented: Bool
    @Published var settingsSheetDissmissDisabled: Bool
    
    // Sample View + Gestures
    @Published var selectedSample: Sample?
    @Published var selectedSampleIndex: Int?
    
    // Gestures
    @Published var offset: CGSize = .zero
    @Published var switchingSamplesAppearance: Bool = false
    
    // Sample View Style
    @Published var samplesAppearance: SampleAppearance
    
    init(cupping: Cupping) {
        self.cupping = cupping
        
        self.settingsSheetIsPresented = cupping.form == nil
        self.settingsSheetDissmissDisabled = cupping.form == nil
        self.selectedSample = nil
        self.selectedSampleIndex = nil
        self.offset = .zero
        self.switchingSamplesAppearance = false
        self.samplesAppearance = .criteria
    }
}

extension CuppingModel {
    var sortedSamples: [Sample] {
        return cupping.getSortedSamples()
    }
}

extension CuppingModel {
    func switchToPreviews() {
        withAnimation {
            selectedSample = nil
            selectedSampleIndex = nil
        }
        samplesAppearance = .preview
    }
}
