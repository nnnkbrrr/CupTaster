//
//  Target Scroll.swift
//  CupTaster
//
//  Created by Никита Баранов on 16.11.2023.
//

import SwiftUI

struct TargetHorizontalScrollView<
    Data: RandomAccessCollection,
    TargetContent: View
>: View where Data.Element: Equatable {
    let data: [(index: Int, value: Data.Element)]
    @Binding var selection: Data.Element?
    @State var selectionIndex: Int?
    let targetContent: (Data.Element) -> TargetContent
    
    let elementWidth: Double
    let spacing: Double
    let contentWidth: Double
    
    @State private var offset: Double
    @State private var tempOffset: Double
    
    // Optional
    
    @Binding var isProcessingGesture: Bool
    
    init (
        _ data: Data,
        selection: Binding<Data.Element?>,
        elementWidth: Double,
        spacing: Double,
        isProcessingGesture: Binding<Bool> = .constant(false),
        @ViewBuilder content targetContent: @escaping (Data.Element) -> TargetContent
    ) {
        let enumeratedData: [(index: Int, value: Data.Element)] = data.enumerated().map { (index: $0.0, value: $0.1) }
        self.data = enumeratedData
        self._selection = selection
        self.targetContent = targetContent
        
        self.elementWidth = elementWidth
        self.spacing = spacing
        self.contentWidth = (elementWidth + spacing) * Double(data.count - 1)
        
        self._isProcessingGesture = isProcessingGesture
        
        self._tempOffset = State(initialValue: 0)
        self._offset = State(initialValue: {
            if let selectedIndex: Int = enumeratedData.first(where: { $1 == selection.wrappedValue })?.index {
                return -(elementWidth + spacing) * Double(selectedIndex)
            } else { return 0 }
        }())
    }
    
    var body: some View {
        Color.clear.frame(height: 55).overlay(alignment: .bottom) {
            HStack(alignment: .top, spacing: spacing) {
                ForEach(data, id: \.index) { targetContent($0.value) }
            }
            .offset(x: contentWidth / 2)
            .offset(x: offset + tempOffset)
        }
        .contentShape(Rectangle())
        .dragGesture(
            gestureType: .simultaneous,
            direction: .horizontal,
            onStart: { isProcessingGesture = true },
            onUpdate: { updateSwipe(horizontalTranslation: $0.translation.width) },
            onEnd: { _ in completeSwipe() },
            onCancel: { completeSwipe() }
        )
    }
    
    private func updateSwipe(horizontalTranslation: CGFloat) {
        guard let selectionIndex: Int = data.first(where: { $1 == selection })?.index else { return }
        
        if (-contentWidth...0) ~= (offset + horizontalTranslation) {
            tempOffset = horizontalTranslation
        } else {
            let directionMultiplier: CGFloat = horizontalTranslation > 0 ? 1 : -1
            let additionalOffset: CGFloat = horizontalTranslation > 0 ? 0 : contentWidth
            
            let boundsOffset: CGFloat = -offset - additionalOffset
            let outOfBoundsOffset: CGFloat = sqrt(horizontalTranslation * directionMultiplier - boundsOffset) * 2.0 * directionMultiplier
            
            tempOffset = boundsOffset + outOfBoundsOffset
        }
        
        for element in data {
            let delta: CGFloat = (-offset - horizontalTranslation) / (elementWidth + spacing)
            let lowerBound: Int = element.index + (element.index <= selectionIndex ? -1 : 0)
            let upperBound: Int = element.index + (element.index >= selectionIndex ? 1 : 0)
            
            if (CGFloat(lowerBound)...CGFloat(upperBound)) ~= delta {
                if element.index != selectionIndex {
                    selection = element.value
                    generateSelectionFeedback()
                }
                break
            }
        }
    }
    
    private func completeSwipe() {
        offset += tempOffset
        tempOffset = 0
        
        withAnimation {
            guard let selection else { return }
            offset = -(elementWidth + spacing) * Double((data.first(where: { $1 == selection })?.index ?? 0))
        }
        
        isProcessingGesture = false
    }
    
    private func generateSelectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
