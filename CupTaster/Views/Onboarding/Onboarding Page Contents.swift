//
//  Onboarding Page Content.swift
//  CupTaster
//
//  Created by Nikita on 24.03.2024.
//

import SwiftUI

struct OnboardingPageContentView<Content: View>: View {
    @Binding var conditionIsFulfilled: Bool
    let content: () -> Content
    let action: () -> ()
    
    init(conditionIsFulfilled: @escaping () -> Bool, content: @escaping () -> Content, action: @escaping () -> ()) {
        self._conditionIsFulfilled = Binding(get: { conditionIsFulfilled() }, set: { _ in })
        self.content = content
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content()
            
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
}
