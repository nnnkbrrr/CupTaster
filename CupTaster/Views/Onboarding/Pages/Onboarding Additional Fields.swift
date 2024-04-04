//
//  Onboarding Additional Fields.swift
//  CupTaster
//
//  Created by Nikita on 24.03.2024.
//

import SwiftUI

struct Onboarding_AdditionalFieldsPage: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: SampleGeneralInfo.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SampleGeneralInfo.title, ascending: false)]
    ) var generalInfoFields: FetchedResults<SampleGeneralInfo>
    
    @ObservedObject var onboardingModel: OnboardingModel
    
    @State var selectedSGITemplates: [String] = []
    
    var body: some View {
        OnboardingPageContents(
            "Additional Fields",
            description: "These fields will available on all cupping forms. You can add more later in settings."
        ) {
            VStack(spacing: .regular) {
                ForEach(suggestedSGITemplates, id: \.self) { suggestion in
                    let isAdded: Bool = selectedSGITemplates.contains(suggestion)
                    
                    Button {
                        if isAdded {
                            selectedSGITemplates.removeAll { $0 == suggestion }
                        } else {
                            selectedSGITemplates.append(suggestion)
                        }
                    } label: {
                        HStack(spacing: .small) {
                            Text(suggestion)
                            
                            if isAdded {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .buttonStyle(.capsule(background: Color.primary.opacity(isAdded ? 1 : 0.5)))
                }
            }
        } conditionIsFulfilled: {
            return true
        } action: {
            withAnimation(.smooth) {
                for sgiTemplate in selectedSGITemplates {
                    let generalInfo: SampleGeneralInfo = .init(context: moc)
                    generalInfo.title = sgiTemplate
                    
                    let sgiTemplates: [SampleGeneralInfo] = generalInfoFields.filter { $0.sample == nil }
                    generalInfo.ordinalNumber = Int16(sgiTemplates.count)
                    try? moc.save()
                }
                onboardingModel.nextPage()
            }
        }
    }
}
