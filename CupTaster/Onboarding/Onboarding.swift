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
    enum OnboardingPages {
        case features, forms, hints
    }
    
    @ObservedObject var cfManager: CFManager = .init()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch currentPage {
                    case .features: OnboardingFeaturesView()
                    case .forms:
                        NavigationView {
                            VStack {
                                Text("What cupping form do you prefer to use?")
                                    .font(.title)
                                    .fontWeight(.heavy)
                                    .multilineTextAlignment(.center)
                                    .padding([.top, .horizontal], 20)
                                
                                SettingsCuppingFormsView(cfManager: cfManager)
                            }
                            .padding(30)
                            .navigationBarHidden(true)
                        }
                    case .hints: OnboardingHintsView()
                }
            }
            .transition(
                .asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                )
            )
            
            Button {
                withAnimation {
                    switch currentPage {
                        case .features: currentPage = .forms
                        case .forms: currentPage = .hints
                        case .hints:
                            onboardingCompleted = true
                            isActive = false
                    }
                }
            } label: {
                Group {
                    switch currentPage {
                        case .features: Text("Get Started")
                        case .forms: Text("Next")
                        case .hints: Text("Finish")
                    }
                }
                .padding(.vertical)
                .foregroundColor(.white)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .background(Color.accentColor)
                .cornerRadius(15)
            }
            .disabled(currentPage == .forms && cfManager.defaultCF_hashedID == 0)
            .padding(50)
            .background(
                LinearGradient(
                    colors: [
                        Color(uiColor: .systemGroupedBackground),
                        Color(uiColor: .systemGroupedBackground).opacity(0)
                    ],
                    startPoint: .bottom,
                    endPoint: .top)
            )
        }
    }
}
