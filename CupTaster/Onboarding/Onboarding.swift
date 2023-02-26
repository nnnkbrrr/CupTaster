//
//  Onboarding.swift
//  CupTaster
//
//  Created by Никита on 29.07.2022.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var onboardingCompleted: Bool
    @Binding var isActive: Bool
    
    @State var currentPage: OnboardingPages = .features
    enum OnboardingPages { case features, forms }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch currentPage {
                case .features: OnboardingFeaturesView()
                case .forms: forms
                }
            }
            .transition(
                .asymmetric(
                    insertion: .move(edge: .bottom),
                    removal: .move(edge: .top)
                )
            )
            .animation(.spring(), value: currentPage)
            
            Button {
                switch currentPage {
                case .features: currentPage = .forms
                case .forms:
                    onboardingCompleted = true
                    isActive = false
                }
            } label: {
                Group {
                    switch currentPage {
                    case .features: Text("Get Started")
                    case .forms: Text("Finish")
                    }
                }
                .padding(.vertical)
                .foregroundColor(.white)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .background(Color.accentColor)
                .cornerRadius(15)
            }
            .disabled(currentPage == .forms && CFManager.shared.defaultCFDescription == "")
            .padding(50)
        }
    }
    
    var forms: some View {
        VStack {
            Text("What cupping form do you prefer to use?")
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
                .padding(20)
            
            List { Settings_CFSelectorFormSectionsView() }
                .cornerRadius(30)
        }
        .padding(30)
    }
}
