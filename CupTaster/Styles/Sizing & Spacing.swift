//
//  Sizing & Spacing.swift
//  CupTaster
//
//  Created by Никита Баранов on 05.07.2023.
//

import SwiftUI

// Spacing

extension Int {
    static let extraSmall: Self = 5
    static let small: Self = 10
    static let regular: Self = 15
    static let large: Self = 20
    static let extraLarge: Self = 40
}

// Size

extension Int {
    static let smallElement: Self = 50
    static let smallElementContainer: Self = 70
}

// Corner Radius

extension Int {
    static let defaultCornerRadius: Self = 15
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

// CGFloat Values

extension CGFloat {
    static let extraSmall: Self = CGFloat(Int.extraSmall)
    static let small: Self = CGFloat(Int.small)
    static let regular: Self = CGFloat(Int.regular)
    static let large: Self = CGFloat(Int.large)
    static let extraLarge: Self = CGFloat(Int.extraLarge)

    static let smallElement: Self = CGFloat(Int.smallElement)
    static let smallElementContainer: Self = CGFloat(Int.smallElementContainer)

    static let defaultCornerRadius: Self = CGFloat(Int.defaultCornerRadius)
}

// Double Values

extension Double {
    static let extraSmall: Self = Double(Int.extraSmall)
    static let small: Self = Double(Int.small)
    static let regular: Self = Double(Int.regular)
    static let large: Self = Double(Int.large)
    static let extraLarge: Self = Double(Int.extraLarge)

    static let smallElement: Self = Double(Int.smallElement)
    static let smallElementContainer: Self = Double(Int.smallElementContainer)

    static let defaultCornerRadius: Self = Double(Int.defaultCornerRadius)
}
