//
//  Onboarding Greetings.swift
//  CupTaster
//
//  Created by Nikita on 09.03.2024.
//

import SwiftUI

struct Onboarding_GreetingsView: View {
    @ObservedObject var onboardingModel: OnboardingModel
    
    var body: some View {
        Spacer()
        
        Image("Logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .matchedGeometryEffect(id: "onboarding-logo", in: NamespaceControllerModel.shared.namespace)
            .frame(width: 100, height: 100)
        
        Group {
            Text("CupTaster")
                .font(.system(size: 40, weight: .bold))
            
            Text("Taste, Analyze, Take Notes")
                .font(.caption)
                .textCase(.uppercase)
        }
        .transition(.scale.combined(with: .offset(y: -250)).combined(with: .opacity))
        
        Spacer()
        
        Image(systemName: "chevron.right")
            .foregroundColor(.white)
            .frame(width: 50, height: 50)
            .background(Color.accentColor)
            .clipShape(Circle())
            .onTapGesture {
                withAnimation(.smooth) {
                    onboardingModel.nextPage()
                }
            }
    }
}
