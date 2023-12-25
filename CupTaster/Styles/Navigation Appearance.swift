//
//  Navigation Appearance.swift
//  CupTaster
//
//  Created by Никита Баранов on 24.12.2023.
//

import SwiftUI

struct Navigation {
    static func configureWithoutBackground() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .clear
        navigationBarAppearance.backgroundEffect = .none
        navigationBarAppearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
}

struct NavigationBackgroundViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .top) {
//                Color.clear.frame(height: 0)
                Divider()
                    .opacity(0.5)
                    .contentShape(Rectangle())
                    .background(.bar)
            }
    }
}

extension View {
    func standardNavigation() -> some View {
        modifier(NavigationBackgroundViewModifier())
    }
}

struct NavigationToolbarViewModifier<ToolbarContent: View>: ViewModifier {
    let toolbarContent: () -> ToolbarContent
    
    init(toolbarContent: @escaping () -> ToolbarContent) {
        self.toolbarContent = toolbarContent
    }
    
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .top) {
                VStack(spacing: 0) {
                    toolbarContent()
                    
                    Divider()
                        .opacity(0.5)
                }
                .background(.bar)
            }
    }
}

extension View {
    func navigationToolbar<ToolbarContent: View>(content: @escaping () -> ToolbarContent) -> some View {
        modifier(NavigationToolbarViewModifier(toolbarContent: content))
    }
}
