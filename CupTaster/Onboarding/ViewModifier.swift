//
//  ViewModifier.swift
//  CupTaster
//
//  Created by Никита on 08.09.2022.
//

import SwiftUI

struct Onboarding: ViewModifier {
    @AppStorage("onboarding-completed") var onboardingCompleted: Bool = false
    @State var isActive: Bool = false
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isActive) {
                OnboardingView (
                    onboardingCompleted: $onboardingCompleted,
                    isActive: $isActive
                )
                .interactiveDismissDisabled()
            }
            .onAppear { if !onboardingCompleted { isActive = true } }
    }
}
