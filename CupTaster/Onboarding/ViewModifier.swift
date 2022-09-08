//
//  ViewModifier.swift
//  CupTaster
//
//  Created by Никита on 08.09.2022.
//

import SwiftUI

struct OnboardingSheet: ViewModifier {
    @AppStorage("onboarding-completed") var onboardingCompleted: Bool = false
    @State var isActive: Bool = false
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isActive) {
                OnboardingView(onboardingCompleted: $onboardingCompleted, isActive: $isActive)
                    .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
                    .interactiveDismissDisabled()
            }
            .onAppear { if !onboardingCompleted { isActive = true } }
    }
}
