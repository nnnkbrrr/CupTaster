//
//  Sample Bottom Sheet.swift
//  CupTaster
//
//  Created by Никита Баранов on 04.11.2023.
//

import SwiftUI


struct SampleBottomSheetView: View {
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.vertical, 5)
            
            Text("Testing bottom sheet")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: .large) {
                    if let sample: Sample = samplesControllerModel.selectedSample { 
                        ForEach(sample.sortedQCGroups) { qcGroup in
                            QCGroupView(qcGroup: qcGroup)
                        }
                    }
                }
            }
            
            Spacer()
                .frame(height: 500)
        }
        .modifier(SheetModifier())
    }
}

extension SampleBottomSheetView {
    struct SheetModifier: ViewModifier {
        @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
        @State var bottomSheetOffset: CGFloat = 0
        
        func body(content: Content) -> some View {
            GeometryReader { geometry in
                content
                    .frame(maxWidth: .infinity)
                    .background(alignment: .top) {
                        HStack {
                            LinearGradient(
                                colors: [.background, .background.opacity(0.25), .background.opacity(0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: .extraLarge)
                            
                            Spacer()
                            
                            LinearGradient(
                                colors: [.background.opacity(0.5), .background.opacity(0)],
                                startPoint: .trailing,
                                endPoint: .leading
                            )
                            .frame(width: .extraLarge)
                        }
                        .frame(height: geometry.frame(in: .global).height * 2)
                        .edgesIgnoringSafeArea(.top)
                        .background(Color.background.opacity(0.25))
                        .background(TransparentBlurView())
                    }
                    .padding(.bottom, geometry.size.height)
                    .offset(
                        y: samplesControllerModel.bottomSheetIsExpanded ?
                        0 : geometry.frame(in: .global).height - samplesControllerModel.bottomSheetMinHeight
                    )
                    .offset(y: bottomSheetOffset)
                    .dragGesture(
                        onUpdate: { value in
                            let translation: CGFloat = value.translation.height
                            if samplesControllerModel.bottomSheetIsExpanded {
                                if translation > 0 {
                                    bottomSheetOffset = translation
                                } else {
                                    let additionalOffset: CGFloat = -sqrt(-translation)
                                    bottomSheetOffset = 0 + additionalOffset
                                }
                            } else {
                                let upperBound: CGFloat = -geometry.frame(in: .global).height + samplesControllerModel.bottomSheetMinHeight
                                if translation > upperBound {
                                    bottomSheetOffset = translation
                                } else {
                                    let additionalOffset: CGFloat = -sqrt(upperBound - translation)
                                    bottomSheetOffset = upperBound + additionalOffset
                                }
                            }
                        }, onEnd: { value in
                            withAnimation(.bouncy) {
                                if value.translation.height < -200 {
                                    samplesControllerModel.bottomSheetIsExpanded = true
                                } else if value.translation.height > 200 {
                                    samplesControllerModel.bottomSheetIsExpanded = false
                                }
                                bottomSheetOffset = 0
                            }
                        }, onCancel: {
                            withAnimation(.bouncy) {
                                bottomSheetOffset = 0
                            }
                        }
                    )
            }
        }
    }
}
