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
                        onStart: { samplesControllerModel.onSwipeStarted() },
                        onUpdate: { samplesControllerModel.onSwipeUpdated(value: $0) },
                        onEnd: { samplesControllerModel.onSwipeEnded(value: $0) },
                        onCancel: { samplesControllerModel.onSwipeCanceled() }
                    )
                
                SampleBottomSheetView()
            }
            .zIndex(1.1)
            .background(Color.background)
            .safeAreaInset(edge: .top, spacing: 0) {
                ZStack {
                    if let cupping = samplesControllerModel.cupping {
                        GeometryReader { geometry in
                            let spacing: CGFloat = .large
                            let sampleOffset: CGFloat = -(geometry.size.width + spacing)
                            
                            HStack(spacing: spacing) {
                                let sortedSamples = cupping.sortedSamples
                                ForEach(sortedSamples) { sample in
                                    let isFirst: Bool = sample.ordinalNumber == 0
                                    let isLast: Bool = sample.ordinalNumber == sortedSamples.last?.ordinalNumber ?? 0
                                    
                                    Text(sample.name)
                                        .frame(width: geometry.size.width)
                                        .frame(height: .smallElementContainer)
                                        .background(.bar)
                                        .cornerRadius()
                                        .rotation3DEffect(
                                            isFirst ? samplesControllerModel.firstSampleRotationAngle : .zero,
                                            axis: (0, 1, 0)
                                        )
                                        .rotation3DEffect(
                                            isLast ? samplesControllerModel.lastSampleRotationAngle : .zero,
                                            axis: (0, 1, 0)
                                        )
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .offset(x: CGFloat(samplesControllerModel.selectedSampleIndex) * sampleOffset)
                            .offset(x: samplesControllerModel.swipeOffset)
                        }
                        .frame(height: .smallElementContainer)
                    }
                    
                    HStack {
                        Button {
                            samplesControllerModel.exit()
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: .smallElement, height: .smallElement)
                                    .foregroundStyle(.bar)
                                Image(systemName: "chevron.left")
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: .smallElement, height: .smallElement)
                                    .foregroundStyle(.bar)
                                Image(systemName: "stopwatch")
                            }
                        }
                    }
                    .padding(.horizontal, .small)
                }
                .padding(.horizontal, .extraSmall)
                .background {
                    LinearGradient(
                        colors: [.background.opacity(0.5), .background.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .edgesIgnoringSafeArea(.top)
                }
                .background(BackdropBlurView(radius: .regular).edgesIgnoringSafeArea(.top))
                .background(alignment: .top) {
                    Color.clear.frame(height: .regular)
                        .background {
                            HStack {
                                LinearGradient(
                                    colors: [.background, .background.opacity(0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .frame(width: .extraLarge)
                                
                                Spacer()
                                
                                LinearGradient(
                                    colors: [.background, .background.opacity(0)],
                                    startPoint: .trailing,
                                    endPoint: .leading
                                )
                                .frame(width: .extraLarge)
                            }
                            .edgesIgnoringSafeArea(.top)
                        }
                        .background(TransparentBlurView().edgesIgnoringSafeArea(.top))
                }
                .background(alignment: .top) {
                    Color.clear.frame(height: 1)
                        .background(TransparentBlurView().edgesIgnoringSafeArea(.top))
                }
                .dragGesture(
                    onStart: { samplesControllerModel.onSwipeStarted() },
                    onUpdate: { samplesControllerModel.onSwipeUpdated(value: $0) },
                    onEnd: { samplesControllerModel.onSwipeEnded(value: $0) },
                    onCancel: { samplesControllerModel.onSwipeCanceled() }
                )
            }
        }
    }
}
