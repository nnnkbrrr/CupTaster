//
//  Active Cupping Samples Model.swift
//  CupTaster
//
//  Created by Никита Баранов on 23.07.2023.
//

import SwiftUI

class SamplesControllerModel: ObservableObject {
    static let shared: SamplesControllerModel = .init()
    var namespace: Namespace.ID
    
    private init() {
        @Namespace var namespace
        self.namespace = namespace
    }
    
    // Sample General Values
    
    @Published private(set) var isActive: Bool = false
    @Published private var isAnimatingOnAppear: Bool = false
    
    @Published private(set) var cupping: Cupping?
    @Published private(set) var selectedSample: Sample?
    @Published public var selectedQCGroup: QCGroup?
    @Published public var selectedCriteria: QualityCriteria?
    
    // Sample Swipe Gestures
    
    @Published private(set) var selectedSampleIndex: Int = 0 // For swipe gestures only
    @Published private(set) var swipeOffset: CGFloat = 0
    @Published private(set) var firstSampleRotationAngle: Angle = .degrees(0)
    @Published private(set) var lastSampleRotationAngle: Angle = .degrees(0)
    @Published private var swipeTransition: Bool = false
    let impactStyle: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    // Sample Bottom Sheet Gestures
    
    @Published public var bottomSheetIsExpanded: Bool = false
}

// General Functions

extension SamplesControllerModel {
    public func setSelectedSample(cupping: Cupping, sample: Sample) {
        if !isAnimatingOnAppear {
            guard cupping.samples.contains(sample) else { return }
            
            withAnimation(.smooth(duration: 0.3)) {
                self.isActive = true
                self.cupping = cupping
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
        self.isAnimatingOnAppear = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isAnimatingOnAppear = false
        }
        
        withAnimation(.smooth(duration: 0.5, extraBounce: 0.3)) {
            self.isActive = false
            self.cupping = nil
            self.selectedSample = nil
            self.selectedSampleIndex = 0
        }
    }
}

// Sample Swipe Functions

extension SamplesControllerModel {
    func onSwipeStarted() {
        changeSelectedSample(sample: nil)
    }
    
    func onSwipeUpdated(value: DragGesture.Value) {
        guard let cupping, cupping.samples.count > 0 else { return }
        let translation: CGFloat = value.translation.width
        
        if translation > 0 {
            if selectedSampleIndex > 0 && !swipeTransition {
                swipeOffset = translation
                firstSampleRotationAngle = .zero
                lastSampleRotationAngle = .zero
            } else {
                self.swipeOffset = 0
                let angle: CGFloat = translation > 360 ? 180 : translation / 2
                if angle > 90 {
                    swipeTransition = true
                    lastSampleRotationAngle = .degrees(-180 + angle)
                    firstSampleRotationAngle = .zero
                    if selectedSampleIndex != cupping.samples.count - 1 {
                        selectedSampleIndex = cupping.samples.count - 1
                        impactStyle.impactOccurred()
                    }
                } else {
                    swipeTransition = false
                    if selectedSampleIndex != 0 {
                        selectedSampleIndex = 0
                        impactStyle.impactOccurred()
                    }
                    firstSampleRotationAngle = .degrees(angle)
                    lastSampleRotationAngle = .zero
                }
            }
        } else {
            if selectedSampleIndex < cupping.sortedSamples.count - 1 && !swipeTransition {
                self.swipeOffset = translation
                self.firstSampleRotationAngle = .zero
                self.lastSampleRotationAngle = .zero
            } else {
                self.swipeOffset = 0
                let angle: CGFloat = translation < -360 ? -180 : translation / 2
                if angle < -90 {
                    self.swipeTransition = true
                    if selectedSampleIndex != 0 {
                        selectedSampleIndex = 0
                        impactStyle.impactOccurred()
                    }
                    self.firstSampleRotationAngle = .degrees(180 + angle)
                    self.lastSampleRotationAngle = .zero
                } else {
                    self.swipeTransition = false
                    if selectedSampleIndex != cupping.samples.count - 1 {
                        selectedSampleIndex = cupping.samples.count - 1
                        impactStyle.impactOccurred()
                    }
                    self.lastSampleRotationAngle = .degrees(angle)
                    self.firstSampleRotationAngle = .zero
                }
            }
        }
    }
    
    func onSwipeEnded(value: DragGesture.Value) {
        guard let cupping, cupping.samples.count > 0 else { return }
        
        let translation: CGFloat = value.translation.width
        let predictedEndTranslation: CGFloat = value.predictedEndTranslation.width
        
        if firstSampleRotationAngle != .zero {
            selectedSampleIndex = 0
            withAnimation(.bouncy) { firstSampleRotationAngle = .zero }
        } else if lastSampleRotationAngle != .zero {
            selectedSampleIndex = cupping.sortedSamples.count - 1
            withAnimation(.bouncy) { lastSampleRotationAngle = .zero }
        } else if abs(translation) > 150 || abs(predictedEndTranslation) > 250 {
            withAnimation(.smooth) {
                selectedSampleIndex = selectedSampleIndex - (translation > 0 ? 1 : -1)
                swipeOffset = 0
            }
        } else {
            withAnimation(.smooth) { swipeOffset = 0 }
        }
        
        changeSelectedSample(sample: cupping.sortedSamples[selectedSampleIndex])
        swipeTransition = false
    }
    
    func onSwipeCanceled() {
        guard let cupping, cupping.samples.count > 0 else { return }
        
        if [swipeOffset, firstSampleRotationAngle.degrees, lastSampleRotationAngle.degrees].contains(where: { $0 != 0 }) {
            withAnimation(.smooth) {
                swipeOffset = 0
                firstSampleRotationAngle.degrees = 0
                lastSampleRotationAngle.degrees = 0
                changeSelectedSample(sample: cupping.sortedSamples[selectedSampleIndex])
            }
        } else {
            changeSelectedSample(sample: cupping.sortedSamples[selectedSampleIndex])
        }
    }
}
