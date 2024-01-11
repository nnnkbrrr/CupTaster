//
//  Sample Bottom Sheet.swift
//  CupTaster
//
//  Created by Никита Баранов on 04.11.2023.
//

import SwiftUI

struct SampleBottomSheetConfiguration {
    static let spacing: CGFloat = BottomSheetConfiguration.spacing
    static let verticalPadding: CGFloat = BottomSheetConfiguration.verticalPadding
    static var minHeight: CGFloat {
        Capsule.height + QCGroup.height + CriteriaPicker.height + Criteria.height + spacing * 3 + verticalPadding * 2
    }
    
    // Capsule Section
    struct Capsule {
        static let width: CGFloat = BottomSheetConfiguration.Capsule.width
        static let height: CGFloat = BottomSheetConfiguration.Capsule.height
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
        VStack(spacing: SampleBottomSheetConfiguration.spacing) {
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(
                    width: SampleBottomSheetConfiguration.Capsule.width,
                    height: SampleBottomSheetConfiguration.Capsule.height
                )
            
            if let sample: Sample = samplesControllerModel.selectedSample,
               let selectedQCGroup: QCGroup = samplesControllerModel.selectedQCGroup {
                TargetHorizontalScrollView(
                    sample.sortedQCGroups,
                    selection: Binding(
                        get: { selectedQCGroup },
                        set: { samplesControllerModel.changeSelectedQCGroup(qcGroup: $0) }
                    ),
                    elementWidth: SampleBottomSheetConfiguration.QCGroup.elementSize,
                    height: SampleBottomSheetConfiguration.QCGroup.height,
                    spacing: SampleBottomSheetConfiguration.QCGroup.spacing,
                    gestureIsActive: $samplesControllerModel.criteriaPickerGestureIsActive
                ) { qcGroup in
                    QCGroupView(qcGroup: qcGroup)
                } onSelectionChange: { newSelection in
                    samplesControllerModel.changeSelectedQCGroup(qcGroup: newSelection)
                }
                .id("\(String(describing: samplesControllerModel.selectedSample?.id)).QCGroups")
            } else {
                SampleQCGroupsPlaceholderView()
            }
            
            if let selectedCriteria = samplesControllerModel.selectedCriteria {
                QualityCriteriaView(criteria: selectedCriteria)
                    .frame(height: SampleBottomSheetConfiguration.Criteria.height)
                    .id(selectedCriteria.id)
            } else {
                SampleCriteriaEvaluationPlaceholderView()
            }
            
            if let selectedQCGroup = samplesControllerModel.selectedQCGroup {
                HStack {
                    ForEach(selectedQCGroup.sortedQualityCriteria) { criteria in
                        Text(criteria.configuration.title)
                            .opacity(criteria == samplesControllerModel.selectedCriteria ? 1 : 0.5)
                            .frame(maxWidth: .infinity)
                            .frame(height: SampleBottomSheetConfiguration.CriteriaPicker.height)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    samplesControllerModel.selectedCriteria = criteria
                                    UISelectionFeedbackGenerator().selectionChanged()
                                }
                            }
                    }
                }
                .padding(.horizontal, .large)
            } else {
                SampleQCGroupPlaceholderView()
            }
            
            let additionalSheetContentOpacity: CGFloat = {
                let bottomSheetOffset: CGFloat = samplesControllerModel.bottomSheetOffset
                
                if samplesControllerModel.bottomSheetIsExpanded {
                    return bottomSheetOffset > 100 ? 0 : 1 - bottomSheetOffset/100
                } else {
                    return bottomSheetOffset < -100 ? 1 : -bottomSheetOffset/100
                }
            }()
            
            VStack(spacing: SampleBottomSheetConfiguration.spacing) {
                SheetNotesSection()
            }
            .padding(.horizontal, .small)
            .opacity(additionalSheetContentOpacity)
        }
        .animation(.easeInOut(duration: 0.5), value: samplesControllerModel.selectedSample)
        .animation(.easeInOut(duration: 0.25), value: samplesControllerModel.selectedCriteria)
        .animation(.easeInOut(duration: 0.1), value: samplesControllerModel.selectedQCGroup)
        .padding(.vertical, SampleBottomSheetConfiguration.verticalPadding)
        .modifier(SheetModifier())
    }
}

extension SampleBottomSheetView {
    struct SheetModifier: ViewModifier {
        @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
        
        func body(content: Content) -> some View {
            GeometryReader { geometry in
                content
                    .frame(maxWidth: .infinity)
                    .background(alignment: .top) {
                        ZStack(alignment: .top) {
                            Color.background.opacity(0.25)
                            
                            TransparentBlurView()
                            
                            LinearGradient(
                                colors: [.background.opacity(0.5), .background.opacity(0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 150)
                            
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
                        }
                        .frame(height: geometry.size.height * 2, alignment: .top)
                        .edgesIgnoringSafeArea(.top)
                    }
                    .offset(
                        y: samplesControllerModel.bottomSheetIsExpanded ?
                        0 : geometry.size.height - SampleBottomSheetConfiguration.minHeight
                    )
                    .offset(y: samplesControllerModel.bottomSheetOffset)
                    .dragGesture(
                        gestureType: .simultaneous,
                        direction: .vertical,
                        onUpdate: { value in
                            let translation: CGFloat = value.translation.height
                            if samplesControllerModel.bottomSheetIsExpanded {
                                if translation > 0 {
                                    samplesControllerModel.bottomSheetOffset = translation
                                } else {
                                    let additionalOffset: CGFloat = -sqrt(-translation)
                                    samplesControllerModel.bottomSheetOffset = 0 + additionalOffset
                                }
                            } else {
                                let upperBound: CGFloat = -geometry.size.height + SampleBottomSheetConfiguration.minHeight
                                if translation > upperBound {
                                    samplesControllerModel.bottomSheetOffset = translation
                                } else {
                                    let additionalOffset: CGFloat = -sqrt(upperBound - translation)
                                    samplesControllerModel.bottomSheetOffset = upperBound + additionalOffset
                                }
                            }
                        }, onEnd: { value in
                            withAnimation(.bouncy) {
                                if value.translation.height < -200 {
                                    samplesControllerModel.bottomSheetIsExpanded = true
                                } else if value.translation.height > 200 {
                                    samplesControllerModel.bottomSheetIsExpanded = false
                                }
                                samplesControllerModel.bottomSheetOffset = 0
                            }
                        }, onCancel: {
                            withAnimation(.bouncy) {
                                samplesControllerModel.bottomSheetOffset = 0
                            }
                        }
                    )
            }
        }
    }
}
