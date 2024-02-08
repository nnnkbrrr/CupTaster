//
//  Active Cupping Samples Model.swift
//  CupTaster
//
//  Created by Никита Баранов on 23.07.2023.
//

import SwiftUI

class SamplesControllerModel: ObservableObject {
    static let shared: SamplesControllerModel = .init()
    private init() { }
    
    enum Page { case main, cupping }
    
    @Published private(set) var isActive: Bool = false
    @Published var isTogglingVisibility: Bool = false
    @Published var stopwatchOverlayIsActive: Bool = false
    
    @Published private(set) var sampleAnimationID: UUID?
    @Published private(set) var cupping: Cupping?
    @Published private(set) var selectedSample: Sample?
    @Published fileprivate(set) var selectedSampleIndex: Int = 0
    @Published public var selectedQCGroup: QCGroup?
    @Published public var selectedCriteria: QualityCriteria?
}

extension SampleGesturesControllerModel {
    func setSelectedSampleIndex(_ index: Int) {
        SamplesControllerModel.shared.selectedSampleIndex = index
    }
}

extension SamplesControllerModel {
    public func setSelectedSample(_ sample: Sample, animationId: UUID? = nil) {
        if !isTogglingVisibility {
            self.isTogglingVisibility = true
            self.sampleAnimationID = animationId
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.isTogglingVisibility = false
            }
            
            withAnimation(.smooth(duration: 0.3)) {
                self.isActive = true
                self.cupping = sample.cupping
                self.selectedSample = sample
                self.selectedSampleIndex = Int(sample.ordinalNumber)
                self.changeSelectedQCGroup(qcGroup: sample.sortedQCGroups.first(where: {
                    !$0.isCompleted
                }) ?? sample.sortedQCGroups.first)
            }
        }
    }
    
    public func changeSelectedSample(sample: Sample?) {
        if let sample {
            self.selectedSample = sample
            self.selectedSampleIndex = Int(sample.ordinalNumber)
            self.changeSelectedQCGroup(qcGroup: sample.sortedQCGroups.first(where: {
                !$0.isCompleted
            }) ?? sample.sortedQCGroups.first)
        } else {
            self.selectedSample = nil
            self.changeSelectedQCGroup(qcGroup: nil)
        }
    }
    
    public func changeSelectedQCGroup(qcGroup: QCGroup?) {
        if let qcGroup {
            self.selectedQCGroup = qcGroup
            self.selectedCriteria = selectedQCGroup?.sortedQualityCriteria.first
        } else {
            self.selectedQCGroup = nil
            self.selectedCriteria = nil
        }
    }
    
    public func exit() {
        self.isTogglingVisibility = true
        
        withAnimation(.bouncy(duration: 0.5)) {
            self.isActive = false
            self.cupping = nil
            self.selectedSample = nil
            self.selectedSampleIndex = 0
        }
        
        DispatchQueue.main.async {
            self.sampleAnimationID = nil
        }
    }
}
