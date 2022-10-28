//
//  Radio View.swift
//  CupTaster
//
//  Created by Никита on 19.07.2022.
//

import SwiftUI

struct RadioView: View {
    @Namespace var namespace
    
    @Binding var value: Double
    let lowerBound: CGFloat
    let upperBound: CGFloat
    let step: CGFloat
    
    var body: some View {
        ZStack {
            if value == 0 {
                Capsule()
                    .foregroundColor(.accentColor.opacity(0))
                    .matchedGeometryEffect(id: "background", in: namespace)
            }
                   
            let values: [Int] = Array(stride(from: lowerBound, through: upperBound, by: step)).map { Int($0) }
            
            HStack {
                ForEach(values, id: \.self) { value in
                    Button {
                        if self.value == Double(value) {
                            self.value = 0
                        } else {
                            self.value = Double(value)
                        }
                    } label: {
                        ZStack {
                            if self.value == Double(value) {
                                Capsule()
                                    .foregroundColor(.gray.opacity(0.25))
                                    .matchedGeometryEffect(id: "background", in: namespace)
                            }
                            
                            Text("\(value)")
                                .bold()
                                .transition(.scale)
                                .foregroundColor(self.value == Double(value) ? .accentColor : .primary)
                                .frame(width: 40, height: 40)
                        }
                        .contentShape(Rectangle())
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(height: 40)
        }
        .animation(
            .interpolatingSpring(stiffness: 150, damping: 15),
            value: self.value
        )
    }
}
