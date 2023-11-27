//
//  Sample Bottom Sheet.swift
//  CupTaster
//
//  Created by Никита Баранов on 04.11.2023.
//

import SwiftUI

struct BottomSheetConfiguration {
    static let spacing: CGFloat = .large
    static let verticalPadding: CGFloat = .extraSmall
    static var minHeight: CGFloat {
        return Capsule.height + QCGroup.height + CriteriaPicker.height + Criteria.height + spacing * 3 + verticalPadding * 2
    }
    
    // Capsule Section
    struct Capsule {
        static let width: CGFloat = 40
        static let height: CGFloat = 5
    }
    
    // Quality Criteria Groups Section
    struct QCGroup {
        static let elementSize: CGFloat = .smallElement
        static let height: CGFloat = elementSize
        static let spacing: CGFloat = .small
    }
    
    // Criteria Picker Section
    struct CriteriaPicker {
        static let height: CGFloat = 25
    }
    
    // Criteria Section
    struct Criteria {
        static let height: CGFloat = .smallElement
    }
    
    // Slider Evaluation
    struct Slider {
        static let elementWidth: CGFloat = 1
        static let height: CGFloat = Criteria.height
        static let spacing: CGFloat = 25
    }
}

struct SampleBottomSheetView: View {
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    
    var body: some View {
        VStack(spacing: BottomSheetConfiguration.spacing) {
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: BottomSheetConfiguration.Capsule.width, height: BottomSheetConfiguration.Capsule.height)
            
            if let sample: Sample = samplesControllerModel.selectedSample,
               let selectedQCGroup: QCGroup = samplesControllerModel.selectedQCGroup {
                TargetHorizontalScrollView(
                    sample.sortedQCGroups,
                    selection: Binding(
                        get: { selectedQCGroup },
                        set: { samplesControllerModel.changeSelectedQCGroup(qcGroup: $0) }
                    ),
                    elementWidth: BottomSheetConfiguration.QCGroup.elementSize,
                    height: BottomSheetConfiguration.QCGroup.height,
                    spacing: BottomSheetConfiguration.QCGroup.spacing
                ) { qcGroup in
                    QCGroupView(qcGroup: qcGroup)
                } onSelectionChange: { newSelection in
                    samplesControllerModel.changeSelectedQCGroup(qcGroup: newSelection)
                }
            }
            
            if let selectedCriteria = samplesControllerModel.selectedCriteria {
                QualityCriteriaView(criteria: selectedCriteria)
                    .frame(height: BottomSheetConfiguration.Criteria.height)
                    .id(selectedCriteria.id)
            }
            
            if let selectedQCGroup = samplesControllerModel.selectedQCGroup {
                HStack {
                    ForEach(selectedQCGroup.sortedQualityCriteria) { criteria in
                        Text(criteria.configuration.title)
                            .opacity(criteria == samplesControllerModel.selectedCriteria ? 1 : 0.5)
                            .frame(maxWidth: .infinity)
                            .frame(height: BottomSheetConfiguration.CriteriaPicker.height)
                            .onTapGesture {
                                withAnimation {
                                    samplesControllerModel.selectedCriteria = criteria
                                }
                            }
                    }
                }
                .padding(.horizontal, .large)
            }
        }
        .padding(.vertical, BottomSheetConfiguration.verticalPadding)
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
                                colors: [.background.opacity(0.5), .background.opacity(0)],
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
                        .frame(height: geometry.frame(in: .global).height * 2, alignment: .top)
                        .edgesIgnoringSafeArea(.top)
                        .background(Color.background.opacity(0.25))
                        .background(TransparentBlurView())
                    }
                    .offset(
                        y: samplesControllerModel.bottomSheetIsExpanded ?
                        0 : geometry.size.height - BottomSheetConfiguration.minHeight
                    )
                    .offset(y: bottomSheetOffset)
                    .dragGesture(
                        gestureType: .simultaneous,
                        direction: .vertical,
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
                                let upperBound: CGFloat = -geometry.size.height + BottomSheetConfiguration.minHeight
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
