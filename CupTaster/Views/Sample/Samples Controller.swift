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
        if samplesControllerModel.isActive {
            ZStack(alignment: .bottom) {
                SampleView()
                    .dragGesture (
                        gestureType: .highPriority,
                        direction: .horizontal,
                        onStart: { samplesControllerModel.onSwipeStarted() },
                        onUpdate: { samplesControllerModel.onSwipeUpdated(value: $0) },
                        onEnd: { samplesControllerModel.onSwipeEnded(value: $0) },
                        onCancel: { samplesControllerModel.onSwipeCanceled() }
                    )
                
                SampleBottomSheetView()
            }
            .zIndex(1.1)
            .background(Color.backgroundPrimary)
            .safeAreaInset(edge: .top, spacing: 0) {
                SamplesControllerPagesView()
            }
            .ignoresSafeArea(samplesControllerModel.bottomSheetIsExpanded ? [] : .keyboard)
            .dragGesture (
                direction: .horizontal,
                onStart: { samplesControllerModel.onSwipeStarted() },
                onUpdate: { samplesControllerModel.onSwipeUpdated(value: $0) },
                onEnd: { samplesControllerModel.onSwipeEnded(value: $0) },
                onCancel: { samplesControllerModel.onSwipeCanceled() }
            )
        }
    }
}
