//
//  Ob Cupping Forms.swift
//  CupTaster
//
//  Created by Никита Баранов on 28.02.2023.
//

import SwiftUI

struct OnboardingFormsView: View {
    @Binding var currentPage: OnboardingView.OnboardingPages
    
    @Binding var selectedCuppingForm: String
    let cuppingForms: [String] = ["SCA", "SCI", "CoE"]
    let formDescriptions: [String: LocalizedStringKey]  = [
        "SCA": "The SCA Cupping Form is the Global Standard used for assessing coffee flavor characteristics and quality.",
        "SCI": "The SCI Cupping Form is calibrated as closely as possible to the SCA form but just being more descriptive.",
        "CoE": "The CoE cupping form is loosely based on the scoring system described in Winetaster's Secrets by Andrew Sharp and on the original SCA Cupping form."
    ]
    
    @Namespace var namespace
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Default cupping form")
                .font(.title3)
                .fontWeight(.heavy)
                .padding(.leading, 5)
            
            HStack(spacing: 10) {
                ForEach(cuppingForms, id: \.self) { cuppingForm in
                    Text(cuppingForm)
                        .fontWeight(.bold)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background {
                            if cuppingForm == selectedCuppingForm {
                                Color.accentColor
                                    .clipShape(Capsule())
                                    .matchedGeometryEffect(id: "capsule-background", in: namespace)
                            }
                        }
                        .onTapGesture {
                            withAnimation(.interpolatingSpring(stiffness: 200, damping: 20)) {
                                selectedCuppingForm = cuppingForm
                            }
                        }
                }
            }
            .overlay {
                Capsule().stroke(Color.accentColor, lineWidth: 3)
            }
            
            Text(formDescriptions[selectedCuppingForm] ?? "")
                .padding(.leading, 5)
            
            Color.clear.frame(height: 50) // button
        }
        .padding(30)
        .background(Color(uiColor: .systemBackground).opacity(0.25))
        .background(.ultraThinMaterial)
        .cornerRadius(40)
        .padding(30)
    }
}
