//
//  Sample Placeholders.swift
//  CupTaster
//
//  Created by Никита Баранов on 08.12.2023.
//

import SwiftUI

struct SampleQCGroupsPlaceholderView: View {
    var body: some View {
        let elementSize: CGFloat = SampleBottomSheetConfiguration.QCGroup.elementSize
        
        Color.clear.frame(height: elementSize).overlay {
            HStack(spacing: SampleBottomSheetConfiguration.QCGroup.spacing) {
                ForEach(0..<15) { _ in
                    Circle()
                        .foregroundStyle(Color.backgroundTertiary)
                        .frame(width: elementSize, height: elementSize)
                }
            }
            .frame(maxWidth: .infinity)
            .opacity(0.5)
        }
        .mask(
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black, .clear]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}

struct SampleCriteriaEvaluationPlaceholderView: View {
    var body: some View {
        ZStack {
            TargetHorizontalScrollView(
                Array(0..<30),
                selection: .constant(15),
                elementWidth: SampleBottomSheetConfiguration.Slider.elementWidth,
                height: SampleBottomSheetConfiguration.Slider.height,
                spacing: SampleBottomSheetConfiguration.Slider.spacing
            ) { _ in
                Capsule()
                    .fill(.gray)
                    .frame(width: 1, height: SampleBottomSheetConfiguration.Slider.height/3)
            }
        }
        .mask(
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black, .clear]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .contentShape(Rectangle())
        .opacity(0.5)
        .disabled(true)
    }
}

struct SampleQCGroupPlaceholderView: View {
    var body: some View {
        Text("Placeholder")
            .redacted(reason: .placeholder)
            .opacity(0.5)
            .frame(maxWidth: .infinity)
            .frame(height: SampleBottomSheetConfiguration.CriteriaPicker.height)
            .padding(.horizontal, .large)
    }
}
