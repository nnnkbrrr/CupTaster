//
//  Target Scroll.swift
//  CupTaster
//
//  Created by Никита Баранов on 16.11.2023.
//

import SwiftUI

fileprivate class GestureBinding: ObservableObject {
    @MainActor static let shared: GestureBinding = .init()
    @Published var isActive: Bool
    init() { self.isActive = false }
}

struct TargetHorizontalScrollView<
    Data: RandomAccessCollection,
    TargetContent: View
>: View where Data.Element: Equatable {
    let data: [(index: Int, value: Data.Element)]
    @Binding var selection: Data.Element
    @State var selectionIndex: Int?
    let targetContent: (Data.Element) -> TargetContent
    let onSelectionChange: (Data.Element) -> ()
    
    let elementWidth: Double
    let height: Double
    let spacing: Double
    let contentWidth: Double
    
    @State private var offset: Double
    @State private var tempOffset: Double
    @Binding var gestureIsActive: Bool
    
    init (
        _ data: Data,
        selection: Binding<Data.Element>,
        elementWidth: Double,
        height: Double,
        spacing: Double,
        gestureIsActive: Binding<Bool>? = nil,
        @ViewBuilder content targetContent: @escaping (Data.Element) -> TargetContent,
        onSelectionChange: @escaping (_ newSelection: Data.Element) -> () = { _ in }
    ) {
        let enumeratedData: [(index: Int, value: Data.Element)] = data.enumerated().map { (index: $0.0, value: $0.1) }
        self.data = enumeratedData
        self._selection = selection
        self.targetContent = targetContent
        self.onSelectionChange = onSelectionChange
        
        self.elementWidth = elementWidth
        self.height = height
        self.spacing = spacing
        self.contentWidth = (elementWidth + spacing) * Double(data.count - 1)
        
        self._gestureIsActive = gestureIsActive ?? Binding(
            get: { GestureBinding.shared.isActive },
            set: { GestureBinding.shared.isActive = $0 }
        )
        
        self._tempOffset = State(initialValue: 0)
        self._offset = State(initialValue: {
            if let selectedIndex: Int = enumeratedData.first(where: { $1 == selection.wrappedValue })?.index {
                return -(elementWidth + spacing) * Double(selectedIndex)
            } else { return 0 }
        }())
    }
    
    var body: some View {
        Color.clear.frame(height: height).overlay {
            HStack(alignment: .top, spacing: spacing) {
                ForEach(data, id: \.index) { element in
                    targetContent(element.value)
                }
            }
            .frame(maxWidth: .infinity)
            .offset(x: contentWidth / 2)
            .offset(x: offset + tempOffset)
        }
        .contentShape(Rectangle())
        .dragGesture(
            gestureType: .simultaneous,
            direction: .horizontal,
            onStart: { gestureIsActive = true },
            onUpdate: { updateSwipe(horizontalTranslation: $0.translation.width) },
            onEnd: { _ in completeSwipe() },
            onCancel: { completeSwipe() }
        )
        .onChange(of: selection) { _ in
            if !gestureIsActive {
                completeSwipe()
            }
        }
    }
    
    private func updateSwipe(horizontalTranslation: CGFloat) {
        guard let selectionIndex: Int = data.first(where: { $1 == selection })?.index else { return }
        
        if (-contentWidth...0) ~= (offset + horizontalTranslation) {
            tempOffset = horizontalTranslation
        } else {
            let directionMultiplier: CGFloat = horizontalTranslation > 0 ? 1 : -1
            let additionalOffset: CGFloat = horizontalTranslation > 0 ? 0 : contentWidth
            
            let boundsOffset: CGFloat = -offset - additionalOffset
            let outOfBoundsOffset: CGFloat = sqrt((horizontalTranslation - boundsOffset) * directionMultiplier) * 2.0 * directionMultiplier
            
            tempOffset = boundsOffset + outOfBoundsOffset
        }
        
        for element in data {
            let delta: CGFloat = (-offset - horizontalTranslation) / (elementWidth + spacing)
            let lowerBound: Int = element.index + (element.index <= selectionIndex ? -1 : 0)
            let upperBound: Int = element.index + (element.index >= selectionIndex ? 1 : 0)
            
            if (CGFloat(lowerBound)...CGFloat(upperBound)) ~= delta {
                if element.index != selectionIndex {
                    self.selection = element.value
                    onSelectionChange(element.value)
                    generateSelectionFeedback()
                }
                break
            } else {
                if delta < CGFloat(lowerBound) && element.index == 0 {
                    self.selection = element.value
                } else if delta > CGFloat(upperBound) && element.index == data.count - 1 {
                    self.selection = element.value
                }
            }
        }
    }
    
    private func completeSwipe() {
        offset += tempOffset
        tempOffset = 0
        
        withAnimation {
            offset = -(elementWidth + spacing) * Double((data.first(where: { $1 == selection })?.index ?? 0))
        }
        
        gestureIsActive = false
    }
    
    private func generateSelectionFeedback() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
