//
//  Onboarding Form Picker.swift
//  CupTaster
//
//  Created by Nikita on 24.03.2024.
//

import SwiftUI

struct Onboarding_FormPickerPage: View {
    @Environment(\.managedObjectContext) private var moc
    
    @ObservedObject var onboardingModel: OnboardingModel
    @ObservedObject var cfManager: CFManager = .shared
    @State var selectedCuppingForm: CFManager.CFModel? = nil
    
    var body: some View {
        let availableCuppingFormModels: [CFManager.CFModel] = cfManager.allCFModels
        
        OnboardingPageContents("Cupping Form", description: "This Cupping Form will be used as a default form, later you can add more forms.") {
            ForEach(availableCuppingFormModels, id: \.id) { cuppingFormModel in
                let isSelected: Bool = selectedCuppingForm?.id == cuppingFormModel.id
                Button {
                    withAnimation(.smooth) {
                        selectedCuppingForm = cuppingFormModel
                    }
                } label: {
                    HStack(spacing: .small) {
                        Text(cuppingFormModel.title)
                        
                        if isSelected {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .buttonStyle(.capsule(background: Color.primary.opacity(isSelected ? 1 : 0.5)))
            }
        } conditionIsFulfilled: {
            selectedCuppingForm != nil
        } action: {
            if let selectedCuppingForm {
                _ = selectedCuppingForm.createCuppingForm(context: moc)
            }
            withAnimation(.smooth) {
                onboardingModel.nextPage()
            }
        }
    }
}
