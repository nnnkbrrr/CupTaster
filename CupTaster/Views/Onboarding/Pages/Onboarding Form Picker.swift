//
//  Onboarding Form Picker.swift
//  CupTaster
//
//  Created by Nikita on 24.03.2024.
//

import SwiftUI

struct Onboarding_FormPickerPage: View {
    @Binding var currentPage: OnboardingView.OnboardingPage
    
    var body: some View {
        OnboardingPageContents("Cupping Form", description: "description") {
            Text("Cupping Form Picker")
        } conditionIsFulfilled: {
            return true
        } action: {
            withAnimation(.smooth) {
                currentPage.nextPage()
            }
        }
    }
}
