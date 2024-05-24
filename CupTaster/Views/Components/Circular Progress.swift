//
//  Circular Progress.swift
//  CupTaster
//
//  Created by Никита Баранов on 26.11.2023.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: CGFloat
    let style: StrokeStyle

    let outlineColor: Color
    let progressColor: Color
    
    init(
        progress: CGFloat,
        style: StrokeStyle = StrokeStyle(lineWidth: 2),
        outlineColor: Color = Color.gray.opacity(0.3),
        progressColor: Color = .accentColor
    ) {
        self.progress = progress
        self.style = style
        self.outlineColor = outlineColor
        self.progressColor = progressColor
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(outlineColor, style: style)
                .rotationEffect(Angle(degrees: 270.0))
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(progressColor, style: StrokeStyle(lineWidth: style.lineWidth, lineCap: .round))
                .rotationEffect(Angle(degrees: 270.0))
                .mask {
                    Circle()
                        .stroke(.white, style: style)
                        .rotationEffect(Angle(degrees: 270.0))
                }
        }
    }
}
