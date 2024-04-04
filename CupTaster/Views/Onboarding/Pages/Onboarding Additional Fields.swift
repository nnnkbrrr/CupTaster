//
//  Onboarding Additional Fields.swift
//  CupTaster
//
//  Created by Nikita on 24.03.2024.
//

import SwiftUI

struct Onboarding_AdditionalFieldsPage: View {
    @Binding var currentPage: OnboardingView.OnboardingPage
    
    var body: some View {
#warning("Additional Fields Picker")
        OnboardingPageContents("Additional Fields", description: "These fields will available on all cupping forms. You can add more later in settings.") {
            Text("Additional Fields Picker")
        } conditionIsFulfilled: {
            return true
        } action: {
            withAnimation(.smooth) {
                currentPage.nextPage()
            }
        }
    }
}
