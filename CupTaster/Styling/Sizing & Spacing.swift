//
//  Sizing & Spacing.swift
//  CupTaster
//
//  Created by Никита Баранов on 05.07.2023.
//

import SwiftUI

extension CGFloat {
    static let extraSmall: Self = 5
    static let small: Self = 10
    static let regular: Self = 15
    static let large: Self = 20
    static let extraLarge: Self = 40
}

// Corner Radius

extension CGFloat {
    static let defaultCornerRadius: Self = 10
}

private struct DefaultCornerRadius: ViewModifier {
    func body(content: Content) -> some View {
        content.cornerRadius(.defaultCornerRadius)
    }
}

extension View {
    func cornerRadius() -> some View {
        modifier(DefaultCornerRadius())
    }
}
