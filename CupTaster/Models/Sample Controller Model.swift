//
//  Active Cupping Samples Model.swift
//  CupTaster
//
//  Created by Никита Баранов on 23.07.2023.
//

import Foundation

class SampleControllerModel: ObservableObject {
    @Published private(set) var cupping: Cupping?
    @Published private(set) var selectedSample: Sample?
    
    static let shared: SampleControllerModel = .init()
    private init() { }
    
    public func setActiveCupping(cupping: Cupping, sample: Sample) {
        guard cupping.samples.contains(sample) else { return }
        
        self.cupping = cupping
        self.selectedSample = sample
    }
    
    public func exit() {
        self.cupping = nil
        self.selectedSample = nil
    }
}
