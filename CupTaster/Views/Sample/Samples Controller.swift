//
//  Sample Controller.swift
//  CupTaster
//
//  Created by Никита Баранов on 23.07.2023.
//

import SwiftUI

struct SamplesControllerView: View {
    @ObservedObject var sampleGesturesControllerModel: SampleGesturesControllerModel = .shared
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    
    var body: some View {
        if samplesControllerModel.isActive {
            ZStack(alignment: .bottom) {
                SampleView()
                    .dragGesture (
                        gestureType: .highPriority,
                        direction: .horizontal,
                        onStart: { sampleGesturesControllerModel.onSwipeStarted() },
                        onUpdate: { sampleGesturesControllerModel.onSwipeUpdated(value: $0) },
                        onEnd: { sampleGesturesControllerModel.onSwipeEnded(value: $0) },
                        onCancel: { sampleGesturesControllerModel.onSwipeCanceled() }
                    )
                
                SampleBottomSheetView()
            }
            .zIndex(1.1)
            .background(Color.backgroundPrimary)
            .safeAreaInset(edge: .top, spacing: 0) {
                SamplesControllerPagesView()
            }
            .ignoresSafeArea(sampleGesturesControllerModel.bottomSheetIsExpanded ? [] : .keyboard)
            .dragGesture (
                direction: .horizontal,
                onStart: { sampleGesturesControllerModel.onSwipeStarted() },
                onUpdate: { sampleGesturesControllerModel.onSwipeUpdated(value: $0) },
                onEnd: { sampleGesturesControllerModel.onSwipeEnded(value: $0) },
                onCancel: { sampleGesturesControllerModel.onSwipeCanceled() }
            )
        }
    }
}
