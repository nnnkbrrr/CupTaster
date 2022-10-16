//
//  Cupping Model.swift
//  CupTaster
//
//  Created by Никита on 24.09.2022.
//

import SwiftUI

class CuppingModel: ObservableObject, Identifiable {
    @Published var cupping: Cupping
    
    // Cupping Settings
    @Published var settingsSheetIsPresented: Bool
    @Published var settingsSheetDismissDisabled: Bool
    
    // Sample View + Gestures
    @Published var sampleViewVisible: Bool = false
    @Published var selectedSample: Sample?
    @Published var selectedSampleIndex: Int?
    
    // Gestures
    @Published var offset: CGSize = .zero
    @Published var switchingSamplesAppearance: Bool
    
    // Samples style
    @Published var samplesAppearance: SampleAppearance
    @Published var samplesEditorActive: Bool
    @Published var selectedHintsQCGConfig: QCGroupConfig?
    
    init(cupping: Cupping) {
        self.cupping = cupping
        
        self.settingsSheetIsPresented = cupping.form == nil
        self.settingsSheetDismissDisabled = cupping.form == nil
        self.selectedSample = nil
        self.selectedSampleIndex = nil
        self.offset = .zero
        self.switchingSamplesAppearance = false
        self.samplesEditorActive = false
        self.samplesAppearance = .criteria
        self.selectedHintsQCGConfig = nil
    }
}

extension CuppingModel {
    var sortedSamples: [Sample] {
        return cupping.getSortedSamples()
    }
}
