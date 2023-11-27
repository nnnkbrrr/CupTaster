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
    
    init(progress: CGFloat, width: CGFloat = 2) {
        self.progress = progress
        self.width = width
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: width)
                .opacity(0.3)
                .foregroundColor(Color.gray)
                .padding(1)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
                .foregroundColor(.accentColor)
                .rotationEffect(Angle(degrees: 270.0))
                .padding(1)
        }
    }
}
