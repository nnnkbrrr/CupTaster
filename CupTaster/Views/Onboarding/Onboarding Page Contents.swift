//
//  Onboarding Page Contents.swift
//  CupTaster
//
//  Created by Nikita on 24.03.2024.
//

import SwiftUI

struct OnboardingPageContents<Content: View>: View {
    let title: String
    let description: String
    let content: () -> Content
    @Binding var conditionIsFulfilled: Bool
    let action: () -> ()
    
    init(_ title: String, description: String, content: @escaping () -> Content, conditionIsFulfilled: @escaping () -> Bool, action: @escaping () -> ()) {
        self.title = title
        self.description = description
        self.content = content
        self._conditionIsFulfilled = Binding(get: { conditionIsFulfilled() }, set: { _ in })
        self.action = action
    }
    
    var body: some View {
        Group {
            Text(title)
                .font(.title)
            
            Text(description)
                .font(.subheadline)
        }
        .multilineTextAlignment(.center)
        .transition(
            .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
            .combined(with: .scale)
            .combined(with: .opacity)
        )
        
        Spacer()
        
        content()
            .transition(
                .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
                .combined(with: .scale)
                .combined(with: .opacity)
            )
        
        Spacer()
        
        Image(systemName: "chevron.right")
            .foregroundColor(.white)
            .frame(width: 50, height: 50)
            .background(Color.accentColor)
            .clipShape(Circle())
            .onTapGesture { action() }
            .disabled(!conditionIsFulfilled)
    }
}
