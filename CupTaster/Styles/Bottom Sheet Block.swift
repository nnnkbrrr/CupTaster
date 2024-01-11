//
//  Bottom Sheet Block.swift
//  CupTaster
//
//  Created by Nikita on 11.01.2024.
//

import SwiftUI

struct BottomSheetBlockView: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: .smallElementContainer)
            .background(Color.backgroundSecondary)
            .cornerRadius()
    }
}

extension View {
    func bottomSheetBlock() -> some View {
        modifier(BottomSheetBlockView())
    }
}

struct BottomSheetBlockButtonView: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: .smallElementContainer)
            .background(configuration.isPressed ? Color.backgroundTertiary : .backgroundSecondary)
            .cornerRadius()
    }
}

struct BottomSheetBlockAccentButtonView: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.background)
            .frame(maxWidth: .infinity)
            .frame(height: .smallElementContainer)
            .background(Color.primary.opacity(configuration.isPressed ? 0.5 : 1))
            .cornerRadius()
    }
}

extension ButtonStyle where Self == BottomSheetBlockButtonView {
    static var bottomSheetBlock: Self { return .init() }
}

extension ButtonStyle where Self == BottomSheetBlockAccentButtonView {
    static var accentBottomSheetBlock: Self { return .init() }
}
