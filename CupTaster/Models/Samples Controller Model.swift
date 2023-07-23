//
//  Active Cupping Samples Model.swift
//  CupTaster
//
//  Created by Никита Баранов on 23.07.2023.
//

import SwiftUI

class SamplesControllerModel: ObservableObject {
    @Published private(set) var cupping: Cupping?
    @Published private(set) var selectedSample: Sample?
    @Published private var isAnimating: Bool = false
    var namespace: Namespace.ID
    
    static let shared: SamplesControllerModel = .init()
    
    private init() {
        @Namespace var namespace
        self.namespace = namespace
    }
    
    public func setActiveCupping(cupping: Cupping, sample: Sample) {
        if !isAnimating {
            guard cupping.samples.contains(sample) else { return }
            
            withAnimation(.smooth(duration: 0.3)) {
                self.cupping = cupping
                self.selectedSample = sample
            }
        }
    }
    
    public func exit() {
        self.isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.isAnimating = false
        }
        
        withAnimation(.smooth(duration: 0.5, extraBounce: 0.3)) {
            self.cupping = nil
            self.selectedSample = nil
        }
    }
}
