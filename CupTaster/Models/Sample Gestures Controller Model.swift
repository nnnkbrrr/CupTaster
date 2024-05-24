//
//  Sample Gestures Controller Model.swift
//  CupTaster
//
//  Created by Nikita on 05.02.2024.
//

import SwiftUI

class SampleGesturesControllerModel: ObservableObject {
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    static let shared: SampleGesturesControllerModel = .init()
    private init() { }
    
    // Sample Swipe Gestures
    
    @Published private(set) var swipeOffset: CGFloat = 0
    @Published private(set) var firstSampleRotationAngle: Angle = .degrees(0)
    @Published private(set) var lastSampleRotationAngle: Angle = .degrees(0)
    @Published private var swipeTransition: Bool = false
    @Published public var samplePickerGestureIsActive: Bool = false
    let impactStyle: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    // Sample Bottom Sheet Gestures
    
    @Published public var bottomSheetIsExpanded: Bool = false
    @Published public var bottomSheetOffset: CGFloat = 0
    @Published public var criteriaPickerGestureIsActive: Bool = false
}

extension SampleGesturesControllerModel {
    func onSwipeStarted() {
        withAnimation(.bouncy(duration: 0.2)) {
            samplesControllerModel.stopwatchOverlayIsActive = false
        }
        samplePickerGestureIsActive = true
        samplesControllerModel.changeSelectedSample(sample: nil)
    }
    
    func onSwipeUpdated(value: DragGesture.Value) {
        guard let cupping = samplesControllerModel.cupping, cupping.samples.count > 0 else { return }
        let translation: CGFloat = value.translation.width
        
        if translation > 0 {
            if samplesControllerModel.selectedSampleIndex > 0 && !swipeTransition {
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
                    if samplesControllerModel.selectedSampleIndex != cupping.samples.count - 1 {
                        setSelectedSampleIndex(cupping.samples.count - 1)
                        impactStyle.impactOccurred()
                    }
                } else {
                    swipeTransition = false
                    if samplesControllerModel.selectedSampleIndex != 0 {
                        setSelectedSampleIndex(0)
                        impactStyle.impactOccurred()
                    }
                    firstSampleRotationAngle = .degrees(angle)
                    lastSampleRotationAngle = .zero
                }
            }
        } else {
            if samplesControllerModel.selectedSampleIndex < cupping.sortedSamples.count - 1 && !swipeTransition {
                self.swipeOffset = translation
                self.firstSampleRotationAngle = .zero
                self.lastSampleRotationAngle = .zero
            } else {
                self.swipeOffset = 0
                let angle: CGFloat = translation < -360 ? -180 : translation / 2
                if angle < -90 {
                    self.swipeTransition = true
                    if samplesControllerModel.selectedSampleIndex != 0 {
                        setSelectedSampleIndex(0)
                        impactStyle.impactOccurred()
                    }
                    self.firstSampleRotationAngle = .degrees(180 + angle)
                    self.lastSampleRotationAngle = .zero
                } else {
                    self.swipeTransition = false
                    if samplesControllerModel.selectedSampleIndex != cupping.samples.count - 1 {
                        setSelectedSampleIndex(cupping.samples.count - 1)
                        impactStyle.impactOccurred()
                    }
                    self.lastSampleRotationAngle = .degrees(angle)
                    self.firstSampleRotationAngle = .zero
                }
            }
        }
    }
    
    func onSwipeEnded(value: DragGesture.Value) {
        guard let cupping = samplesControllerModel.cupping, cupping.samples.count > 0 else { return }
        
        let translation: CGFloat = value.translation.width
        let predictedEndTranslation: CGFloat = value.predictedEndTranslation.width
        
        if firstSampleRotationAngle != .zero {
            setSelectedSampleIndex(0)
            withAnimation(.bouncy) { firstSampleRotationAngle = .zero }
        } else if lastSampleRotationAngle != .zero {
            setSelectedSampleIndex(cupping.sortedSamples.count - 1)
            withAnimation(.bouncy) { lastSampleRotationAngle = .zero }
        } else if abs(translation) > 150 || abs(predictedEndTranslation) > 250 {
            withAnimation(.bouncy) {
                self.setSelectedSampleIndex(samplesControllerModel.selectedSampleIndex - (translation > 0 ? 1 : -1))
                swipeOffset = 0
            }
        } else {
            withAnimation(.bouncy) { swipeOffset = 0 }
        }
        
        samplesControllerModel.changeSelectedSample(sample: cupping.sortedSamples[samplesControllerModel.selectedSampleIndex])
        swipeTransition = false
        samplePickerGestureIsActive = false
    }
    
    func onSwipeCanceled() {
        guard let cupping = samplesControllerModel.cupping, cupping.samples.count > 0 else { return }
        
        if [swipeOffset, firstSampleRotationAngle.degrees, lastSampleRotationAngle.degrees].contains(where: { $0 != 0 }) {
            withAnimation(.smooth) {
                swipeOffset = 0
                firstSampleRotationAngle.degrees = 0
                lastSampleRotationAngle.degrees = 0
                samplesControllerModel.changeSelectedSample(sample: cupping.sortedSamples[samplesControllerModel.selectedSampleIndex])
            }
        } else {
            samplesControllerModel.changeSelectedSample(sample: cupping.sortedSamples[samplesControllerModel.selectedSampleIndex])
        }
        samplePickerGestureIsActive = false
    }
}
