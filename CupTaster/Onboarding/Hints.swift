//
//  Hints.swift
//  CupTaster
//
//  Created by Никита on 08.09.2022.
//

import SwiftUI

struct OnboardingHintsView: View {
    @AppStorage("use-cupping-hints") var useCuppingHints: Bool = true
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                Text("Do you want to turn hints on?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 50)
                
                HStack(spacing: 30) {
                    Text("No")
                        .font(.title2)
                        .fontWeight(.black)
                        .scaleEffect(useCuppingHints ? 0.5 : 1.5)
                        .opacity(useCuppingHints ? 0.5 : 1.0)
                    
                    Toggle("", isOn: $useCuppingHints)
                        .labelsHidden()
                    
                    Text("Yes")
                        .font(.title2)
                        .fontWeight(.black)
                        .scaleEffect(useCuppingHints ? 1.5 : 0.5)
                        .opacity(useCuppingHints ? 1.0 : 0.5)
                }
            }
            .animation(.spring(), value: useCuppingHints)
            .multilineTextAlignment(.center)
            .padding(50)
        }
    }
}
