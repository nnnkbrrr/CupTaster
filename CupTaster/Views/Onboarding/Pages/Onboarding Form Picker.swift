//
//  Onboarding Form Picker.swift
//  CupTaster
//
//  Created by Nikita on 24.03.2024.
//

import SwiftUI

struct Onboarding_FormPickerPage: View {
    @ObservedObject var onboardingModel: OnboardingModel
    
    var body: some View {
#warning("Cupping Form Picker")
        OnboardingPageContents("Cupping Form", description: "This Cupping Form will be used as a default form, later you can add more forms.") {
            Text("Cupping Form Picker")
        } conditionIsFulfilled: {
            return true
        } action: {
            withAnimation(.smooth) {
                onboardingModel.nextPage()
            }
        }
    }
}
