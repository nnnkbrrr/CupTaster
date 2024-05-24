//
//  Resizable Text.swift
//  CupTaster
//
//  Created by Nikita on 11.01.2024.
//

import SwiftUI

extension View {
    func resizableText(initialSize: CGFloat = 34, weight: Font.Weight? = nil) -> some View {
        return self
            .font(.system(size: initialSize).weight(weight ?? .regular))
            .minimumScaleFactor(0.01)
    }
}
