//
//  Bottom Sheet Block.swift
//  CupTaster
//
//  Created by Nikita on 11.01.2024.
//

import SwiftUI

struct BottomSheetBlockView: ViewModifier {
    let height: CGFloat?
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: height ?? .smallElementContainer)
            .background(Color.backgroundSecondary)
            .cornerRadius()
    }
}

extension View {
    func bottomSheetBlock(height: CGFloat? = nil) -> some View {
        modifier(BottomSheetBlockView(height: height))
    }
}

struct BottomSheetBlockButtonView: ButtonStyle {
    let height: CGFloat?
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: height ?? .smallElementContainer)
            .background(configuration.isPressed ? Color.backgroundTertiary : .backgroundSecondary)
            .cornerRadius()
    }
}

struct BottomSheetBlockAccentButtonView: ButtonStyle {
    let height: CGFloat?
    
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
    static func bottomSheetBlock(height: CGFloat? = nil) -> Self {
        return .init(height: height)
    }
    
    static var bottomSheetBlock: Self {
        return .init(height: nil)
    }
}

extension ButtonStyle where Self == BottomSheetBlockAccentButtonView {
    static func accentBottomSheetBlock(height: CGFloat? = nil) -> Self {
        return .init(height: height)
    }
    
    static var accentBottomSheetBlock: Self {
        return .init(height: nil)
    }
}
