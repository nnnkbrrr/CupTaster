//
//  Circular Progress.swift
//  CupTaster
//
//  Created by Никита Баранов on 26.11.2023.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: CGFloat
    let width: CGFloat

    let outlineColor: Color
    let progressColor: Color
    
    init(progress: CGFloat, width: CGFloat = 2, outlineColor: Color = Color.gray.opacity(0.3), progressColor: Color = .accentColor) {
        self.progress = progress
        self.width = width
        self.outlineColor = outlineColor
        self.progressColor = progressColor
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: width)
                .foregroundColor(outlineColor)
                .padding(1)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
                .foregroundColor(progressColor)
                .rotationEffect(Angle(degrees: 270.0))
                .padding(1)
        }
    }
}
