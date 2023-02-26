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
            .fullScreenCover(isPresented: $isActive) {
                OnboardingView (
                    onboardingCompleted: $onboardingCompleted,
                    isActive: $isActive
                )
                .background(
                    Image("onboarding-background")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay {
                            LinearGradient(
                                colors: [.black.opacity(0.75), .black.opacity(0), .black.opacity(0.75)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                        .ignoresSafeArea()
                )
                .interactiveDismissDisabled()
            }
            .onAppear { if !onboardingCompleted { isActive = true } }
    }
}
